package org.sqlcomponents.compiler.java.mapper.postgresql;

import org.junit.jupiter.api.Test;

import java.net.InetAddress;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static  org.sqlcomponents.compiler.java.util.CompilerTestUtil.getDataType;
class PGNetworkMacaddrTypeTest {

    @Test
    void testDataType() throws Exception {

        assertEquals(String.class, Class.forName(getDataType("a_macaddr")), "Type Mismatch");


    }
}
