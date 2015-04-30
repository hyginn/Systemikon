/*
 * Copyright (c) 2006 Gregor Heinrich. All rights reserved. Redistribution and
 * use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met: 1. Redistributions of source
 * code must retain the above copyright notice, this list of conditions and the
 * following disclaimer. 2. Redistributions in binary form must reproduce the
 * above copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the distribution.
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESSED OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * Created on 04.08.2006
 */
package org.knowceans.mcl;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

import org.knowceans.util.Vectors;

/**
 * MatrixLoader loads matrices in simple sparse and dense formats.
 *
 * @author gregor :: arbylon . net
 */
public class MatrixLoader {

    public static void main(String[] args) {
        double[][] a = loadDense("m.txt");
        System.out.println(Vectors.print(a));
    }

    /**
     * read a graph with line format labelfrom labelto weight
     *
     * @param string
     */
    public static SparseMatrix loadSparse(String file) {
        SparseMatrix matrix = new SparseMatrix();
        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line = null;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split(" ");
                if (parts.length < 2) {
                    System.out.println("Warning: wrong line format (1)");
                    continue;
                }
                int from = Integer.parseInt(parts[0].trim());
                int to = Integer.parseInt(parts[1].trim());
                double weight = 1.;
                if (parts.length > 2) {
                    weight = Double.parseDouble(parts[2].trim());
                }
                matrix.add(from, to, weight);

            }
            br.close();
            return matrix;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * read a graph with the elements of the adjacency matrix in each line.
     *
     * @param file
     * @return
     */
    public static double[][] loadDense(String file) {
        ArrayList<double[]> matrix = new ArrayList<double[]>();
        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line = null;
            while ((line = br.readLine()) != null) {
                String[] parts = line.trim().split("[ ,] *");
                double[] vec = new double[parts.length];

                for (int i = 0; i < parts.length; i++) {
                    vec[i] = Double.parseDouble(parts[i].trim());
                }
                matrix.add(vec);
            }
            br.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return matrix.toArray(new double[0][]);
    }

}
