package com.wdm.xpartiture;

import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.wdm.xpartiture.exist.ExistAccess;
import com.wdm.xpartiture.exist.ExistQuery;
import com.wdm.xpartiture.helper.Base64Encoder;
import spark.Request;
import spark.Response;
import spark.Route;
import spark.servlet.SparkApplication;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.List;
import java.util.Map;

import static spark.Spark.get;

/**
 * Created by ane on 5/31/14.
 */
public class XPartitureWebService implements SparkApplication {

    private final String MUSIC_FILE_PATH = "/db/music/";
    private final String PATH_TO_CONVERTER = "/Applications/LilyPond.app/Contents/Resources/bin/";

    public String printStackTrace(Exception e) {
        StringWriter sw = new StringWriter();
        e.printStackTrace(new PrintWriter(sw));
        return sw.toString();
    }

    @Override
    public void init() {

        get(new Route("/") {
            @Override
            public Object handle(final Request request, final Response response) {
                return "XPartiture is On!";
            }
        });

        get(new Route("/musicScorePdf") {
            @Override
            public Object handle(final Request request, final Response response) {
                try {
                    FileInputStream file = new FileInputStream(new File("output4midi.pdf"));
                    HttpServletResponse http = response.raw();
                    http.setContentType("application/pdf");

                    byte buffer[] = new byte[8192];
                    int bytesRead;

                    BufferedInputStream bis = new BufferedInputStream(file);
                    OutputStream os = http.getOutputStream();
                    while ((bytesRead = bis.read(buffer)) != -1) {
                        os.write(buffer, 0, bytesRead);
                    }
                    file.close();
                    os.flush();
                    os.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return response;
            }
        });

        get(new Route("/musicScoreMidi") {
            @Override
            public Object handle(final Request request, final Response response) {

//                try {
//                    FileInputStream file = new FileInputStream(new File());
//                    HttpServletResponse http = response.raw();
//                    http.setContentType("audio/midi");
//
//                    byte buffer[] = new byte[8192];
//                    int bytesRead;
//
//                    BufferedInputStream bis = new BufferedInputStream(file);
//                    OutputStream os = http.getOutputStream();
//                    os.write(base64.getBytes());
//                    while ((bytesRead = bis.read(buffer)) != -1) {
//                        os.write(buffer, 0, bytesRead);
//                    }
//                    file.close();
//                    os.flush();
//                    os.close();
//                } catch (Exception e) {
//                    e.printStackTrace();
//                }
//                return response;

                JsonObject result = new JsonObject();
                try {
                    String base64 = Base64Encoder.encodeFileToBase64Binary("output4midi.midi");
                    result.addProperty("result", base64);
                    result.addProperty("successful", true);
                } catch (Exception e) {
                    result.addProperty("result", e.getMessage() == null ? printStackTrace(e) : e.getMessage());
                    result.addProperty("successful", false);
                }
                String callback = request.queryParams("callback");
                return callback + "(" + result.toString() + ")";
            }
        });

        get(new Route("/musicFile/:filename") {
            @Override
            public Object handle(final Request request, final Response response) {
                String filename = request.params("filename");

                JsonObject result = new JsonObject();
                try {
                    result.addProperty("result", ExistAccess.getXmlDocument(MUSIC_FILE_PATH, filename));
                    System.out.println(result.get("result"));
                    result.addProperty("successful", true);
                } catch (Exception e) {
                    result.addProperty("result", e.getMessage() == null ? printStackTrace(e) : e.getMessage());
                    result.addProperty("successful", false);
                }
                String callback = request.queryParams("callback");
                return callback + "(" + result.toString() + ")";

            }
        });

        get(new Route("/listMusicFiles") {
            @Override
            public Object handle(final Request request, final Response response) {

                JsonObject result = new JsonObject();
                try {
                    List<String> list = ExistAccess.listCollectionResources(MUSIC_FILE_PATH);
                    result.add("result", new GsonBuilder().create().toJsonTree(list));
                    result.addProperty("successful", true);
                } catch (Exception e) {
                    result.addProperty("result", e.getMessage() == null ? printStackTrace(e) : e.getMessage());
                    result.addProperty("successful", false);
                }
                String callback = request.queryParams("callback");
                return callback + "(" + result.toString() + ")";
            }
        });

        get(new Route("/musicScore/:filename") {
            @Override
            public Object handle(final Request request, final Response response) {
                String filename = request.params("filename");
                JsonObject result = new JsonObject();
                try {

                    String xml = ExistAccess.getXmlDocument(MUSIC_FILE_PATH, filename);

                    File input = new File("input.xml");
                    BufferedWriter writer = new BufferedWriter(new FileWriter(input));
                    writer.write(xml);
                    writer.flush();
                    writer.close();

                    Runtime r = Runtime.getRuntime();
                    Process p = r.exec(PATH_TO_CONVERTER + "musicxml2ly -o output.ly input.xml");
                    p.waitFor();

                    File lily = new File("output.ly");
                    File lily4midi = new File("output4midi.ly");
                    BufferedWriter lilyWriter = new BufferedWriter(new FileWriter(lily4midi));
                    if (!lily.exists())
                        throw new RuntimeException("Converted file not found");
                    BufferedReader reader = new BufferedReader(new FileReader(lily));
                    String line;
                    String score = "";
                    while ((line = reader.readLine()) != null) {
                        if (line.contains("\\midi")) {
                            line = line.replace("%", "");
                        }
                        score += line + "\n";
                        lilyWriter.write(line + "\n");
                    }
                    reader.close();
                    lilyWriter.flush();
                    lilyWriter.close();

                    p = r.exec(PATH_TO_CONVERTER + "lilypond output4midi.ly");
                    p.waitFor();

                    JsonObject details = new JsonObject();
                    details.addProperty("score", score);
                    Map<String, String> dets = ExistQuery.getScoreDetails(MUSIC_FILE_PATH, filename);
                    details.add("details", new GsonBuilder().create().toJsonTree(dets));

                    result.add("result", details);
                    result.addProperty("successful", true);
                } catch (Exception e) {
                    result.addProperty("result", e.getMessage() == null ? printStackTrace(e) : e.getMessage());
                    result.addProperty("successful", false);
                }
                String callback = request.queryParams("callback");
                return callback + "(" + result.toString() + ")";
            }
        });

    }
}
