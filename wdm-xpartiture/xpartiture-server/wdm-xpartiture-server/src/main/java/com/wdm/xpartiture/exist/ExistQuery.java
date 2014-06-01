package com.wdm.xpartiture.exist;

import org.exist.xmldb.XQueryService;
import org.xmldb.api.base.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by ane on 5/31/14.
 */
public class ExistQuery {

    public static Map<String, String> getScoreDetails(String path, String resource) throws ClassNotFoundException, InstantiationException, XMLDBException, IllegalAccessException {
        Map<String, String> result = new HashMap<String, String>();
        Collection col = ExistAccess.getCollection(path);
        String doc = "doc('" + resource + "')";
        String xQuery;
        result.put( "work",  executeQuery(col, doc+"//work-title/text()"));
        result.put( "movement", executeQuery(col, doc+"//movement-title/text()"));
        xQuery = "for $creator in "+doc+"//creator\n" +
                "    return concat($creator/@type, '=', $creator/text())";
        try {
            for (String creator : executeQuery(col, xQuery).split("#")) {
                String[] parts = creator.split("=");
                result.put(parts[0], parts[1]);
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        xQuery = "declare function local:buildLyrics($lyric_list, $result){\n" +
                "    if (count($lyric_list)>0) then (\n" +
                "        let $lyric := $lyric_list[1]\n" +
                "        return\n" +
                "            if($lyric/syllabic/text() = 'single' or $lyric/syllabic/text() = 'end') then\n" +
                "                local:buildLyrics(subsequence($lyric_list, 2), concat($result, $lyric/text/text(), ' '))\n" +
                "            else \n" +
                "                local:buildLyrics(subsequence($lyric_list, 2), concat($result, $lyric/text/text()))\n" +
                "    )\n" +
                "    else $result\n" +
                "};\n" +
                "\n" +
                "let $lyrics := "+doc+"//lyric return\n" +
                "for $i in distinct-values($lyrics/@number)\n" +
                "return local:buildLyrics($lyrics[@number = $i], '')";
        result.put( "lyrics", executeQuery(col, xQuery).replace('#', '\n'));
        return result;
    }

    private static String executeQuery(Collection col, String query) throws XMLDBException {
        // query a document

        // Instantiate a XQuery service
        XQueryService service = (XQueryService) col.getService("XQueryService", "1.0");
        service.setProperty("indent", "yes");

        // Execute the query, print the result
        ResourceSet result = service.query(query);
        ResourceIterator i = result.getIterator();
        String out = "";
        while (i.hasMoreResources()) {
            Resource r = i.nextResource();
           out += "#"+(String) r.getContent();
        }
        return out.length()>0? out.substring(1) : out;
    }

    public static void main(String[] args) throws Exception {

        System.out.println(getScoreDetails("/db/music/", "BeetAnGeSample.xml"));

    }

}
