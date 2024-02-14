package org.example;

import java.io.File;
import java.io.InputStream;

public class Main {
    public static final String ROOT = "/Users/fefendi/java/git/FuadEfendi/env";

    public static void main(String[] args) {
        String key = "";
        //File inputFile = new File("apache-maven-3.8.8-bin.zip");
        String filename = "puttygen";
        File encryptedFile = new File(ROOT, filename + ".crc");
        File decryptedFile = new File(ROOT, filename + ".exe");
        try {
            CryptoUtils.encrypt(key, decryptedFile, encryptedFile);
            //CryptoUtils.decrypt(key, encryptedFile, decryptedFile);
        } catch (CryptoException ex) {
            System.out.println(ex.getMessage());
            ex.printStackTrace();
        }
    }
}