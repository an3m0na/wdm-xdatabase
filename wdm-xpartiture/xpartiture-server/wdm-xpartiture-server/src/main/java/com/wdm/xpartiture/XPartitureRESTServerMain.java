package com.wdm.xpartiture;

import static spark.Spark.setPort;

/**
 * Created by ane on 5/31/14.
 */
public class XPartitureRESTServerMain {
    public static void main(String[] args) {
        String port = System.getenv("PORT");
        setPort(port == null ? 9090 : Integer.parseInt(port));
        new XPartitureWebService().init();

    }

}
