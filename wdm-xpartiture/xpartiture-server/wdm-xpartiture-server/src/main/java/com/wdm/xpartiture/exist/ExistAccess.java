package com.wdm.xpartiture.exist;

import org.xmldb.api.DatabaseManager;
import org.xmldb.api.base.Collection;
import org.xmldb.api.base.Database;
import org.xmldb.api.base.XMLDBException;
import org.xmldb.api.modules.XMLResource;

import java.util.Arrays;
import java.util.List;

/**
 * Created by ane on 5/31/14.
 */
public class ExistAccess {
    protected static String DRIVER = "org.exist.xmldb.DatabaseImpl";
    protected static String URI = "xmldb:exist://localhost:8080/exist/xmlrpc";
    protected static String collectionPath = "/db/movies/";
    protected static String resourceName = "movies.xml";

    public static String getXmlDocument() throws XMLDBException, ClassNotFoundException, InstantiationException, IllegalAccessException {
        return getXmlDocument(collectionPath, resourceName);
    }

    public static String getXmlDocument(String path, String resource) throws XMLDBException, ClassNotFoundException, IllegalAccessException, InstantiationException {
        Collection col = getCollection(path);

        // get the content of a document
        System.out.println("Get the content of " + resource);
        XMLResource res = (XMLResource) col.getResource(resource);

        if (res == null) {
            System.out.println("document not found!");
            return null;
        } else {
            return res.getContent().toString();
        }
    }

    public static List<String> listCollectionResources(String path) throws XMLDBException, ClassNotFoundException, IllegalAccessException, InstantiationException {
        Collection col = getCollection(path);
        return Arrays.asList(col.listResources());
    }

    protected static Collection getCollection(String path) throws ClassNotFoundException, XMLDBException, IllegalAccessException, InstantiationException {
        // initialize database driver
        Class cl = Class.forName(DRIVER);
        Database database = (Database) cl.newInstance();
        DatabaseManager.registerDatabase(database);

        // get the collection
        return DatabaseManager.getCollection(URI + path);

    }

    public static void main(String[] args) throws Exception {
        System.out.println(getXmlDocument());
    }



}
