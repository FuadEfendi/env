package org.example;

import java.io.File;
import java.io.InputStream;

public class Main {
    public static void main(String[] args) {
        //System.out.println("Hello world!");



        
            try {
                CryptoUtils.encrypt(key, inputFile, encryptedFile);
                CryptoUtils.decrypt(key, encryptedFile, decryptedFile);
            } catch (CryptoException ex) {
                System.out.println(ex.getMessage());
                ex.printStackTrace();
            }



    }

    // 1, 2, 3, 4, 5,99, 1
    // output: 99,5,4,3
    // print top 4

    public static void printTopHighestN(int n, InputStream i) {
        /*


  PRODUCER: stock prices, different sources, put into single queue
  consumer(s): get price, put into _same_ database
  chronological order

  MESSAGE
        SYMBOL
        PRICE
        TIMESTAMP: clustered unique time-based UUID, we can have many producers

  PARTITIONING BY SYMBOL to enable multiple consumers: A, B, C, ...

  CONSUMER {
    onConfigChange(message){

    }
   }

  (SYMBOL, TIMESTAMP)


  HASH_CODE
  NUMBER_OF_PARTITIONS


  BUCKET = HASH_CODE % NUMBER_OF_PARTITIONS

        ====================================

        EMP (EMP_ID, NAME, DOJ)
        SALARY(ID, EMP_ID, SALARY)

        find names of all EMP who has top Kth (top 3rd) salary, sort by dateof joining ASC

        1000, 100, 10, 1 // who has 10 salary?

        WITH (SELECT DISTINCT SALARY FROM SALARY DESC LIMIT K) AS topK,  // 1000, 100, 10
        WITH (SELECT * FROM topK DESC LIMIT 1) as topKsalary, // 10
        SELECT NAME, SALARY FROM EMP INNER JOIN SALARY ON EMP.EMP_ID=SALARY.EMP_ID HAVING SALARY = topKsalary



         */

    }

}