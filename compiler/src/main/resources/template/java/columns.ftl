<#include "base.ftl">
<#macro columnheader property>
    public static class ${property.name?cap_first}Column extends Column<${getClassName(property.dataType)}> {
    private String sql;

    public ${property.name?cap_first}Column(final PartialWhereClause  whereClause) {
    super(whereClause);
    }

    public String name() {
    return "${property.column.escapedName?j_string}";
    }

    <@ColumnFoundation property=property/>

</#macro>

<#macro columnfooter property>
    @Override
    public String asSql() {
    return sql;
    }

    public boolean validate(${getClassName(property.dataType)} value) {
    return true;
    }

    }
</#macro>

<#macro ColumnFoundation property>
    public final WhereClause isNull() {
    sql = "${property.column.escapedName?j_string} IS NULL";
    return getWhereClause();
    }

    public final WhereClause isNotNull() {
    sql = "${property.column.escapedName?j_string} IS NOT NULL";
    return getWhereClause();
    }
</#macro>

<#macro StringColumn property>
    <@columnheader property=property/>

    public void set(final PreparedStatement preparedStatement, final int i, final String value) throws SQLException {
    <#if property.column.typeName == "macaddr8" >
    PGobject pgObject = new PGobject();
     pgObject.setType("macaddr8");
    pgObject.setValue(value);
    preparedStatement.setObject(i, pgObject);
     <#elseif property.column.typeName == "macaddr" >
    PGobject pgObject = new PGobject();
     pgObject.setType("macaddr");
    pgObject.setValue(value);
    preparedStatement.setObject(i, pgObject);
   
    <#elseif property.column.typeName == "path" >
    PGobject pgObject = new PGobject();
     pgObject.setType("path");
    pgObject.setValue(value);
    preparedStatement.setObject(i, pgObject);
    <#else>
    preparedStatement.setString(i,value);
    </#if>
    }

    @Override
    public String get(final ResultSet resultSet, final int i) throws SQLException {
        return resultSet.getString(i);
    }

    public final WhereClause  eq(final String value) {
    sql = "${property.column.escapedName?j_string} ='" + value + "'";
    return getWhereClause();
    }

    public final WhereClause LIKE(final String value) {
    sql = "${property.column.escapedName?j_string} LIKE '" + value + "'";
    return getWhereClause();
    }

    <@columnfooter property=property/>
</#macro>

<#macro UUIDColumn property>
    <@columnheader property=property/>
    public void set(final PreparedStatement preparedStatement, final int i, final UUID value) throws SQLException {
    preparedStatement.setObject(i,convertUuid(value), java.sql.Types.OTHER);
    }

    public UUID get(final ResultSet rs,final int index) throws SQLException {
        return (UUID) rs.getObject(index);
    }

    public final WhereClause  eq(final UUID value) {
    sql = "${property.column.escapedName?j_string} ='" + value.toString() + "'";
    return getWhereClause();
    }
    <@columnfooter property=property/>
</#macro>

<#macro DurationColumn property>
    <@columnheader property=property/>
    public void set(final PreparedStatement preparedStatement, final int i, final Duration value) throws SQLException {
    preparedStatement.setObject(i,convertInterval(value));
    }

    public Duration get(final ResultSet rs,final int index) throws SQLException {
        final PGInterval interval = (PGInterval) rs.getObject(index);

        if (interval == null) {
            return null;
        }

        final int days = interval.getDays();
        final int hours = interval.getHours();
        final int minutes = interval.getMinutes();
        final double seconds = interval.getSeconds();

        return Duration.ofDays(days)
                .plus(hours, ChronoUnit.HOURS)
                .plus(minutes, ChronoUnit.MINUTES)
                .plus((long) Math.floor(seconds), ChronoUnit.SECONDS);
    }

    public final WhereClause  eq(final String value) {
    sql = "${property.column.escapedName?j_string} ='" + value + "'";
    return getWhereClause();
    }

    

    <@columnfooter property=property/>
</#macro>

<#macro ByteBuffer property>
    <@columnheader property=property/>
    public void set(final PreparedStatement preparedStatement, final int i, final ByteBuffer value) throws SQLException {
    preparedStatement.setBytes(i,value == null ? null : value.array());
    }
    @Override
    public ByteBuffer get(final ResultSet resultSet, final int i) throws SQLException {
        return resultSet.getBytes(i) == null ? null : ByteBuffer.wrap(resultSet.getBytes(i));
    }
    public final WhereClause  eq(final String value) {
    sql = "${property.column.escapedName?j_string} ='" + value + "'";
    return getWhereClause();
    }
    <@columnfooter property=property/>
</#macro>

<#macro JsonNodeColumn property>
    <@columnheader property=property/>

    public void set(final PreparedStatement preparedStatement, final int i, final  JsonNode jsonNode) throws SQLException {
    final String jsonText  = (jsonNode == null) ? null : jsonNode.toString() ;
    preparedStatement.setObject(i,jsonText, java.sql.Types.OTHER);
    }

    public JsonNode get(final ResultSet rs,final int index) throws SQLException {
        String jsonText = rs.getString(index);
        if (jsonText == null) {
            return null;
        }

        try {
            return new ObjectMapper().readTree(jsonText);
        } catch (JsonProcessingException e) {
            throw new SQLException(e);
        }
    }

    public final WhereClause  eq(final String value) {
    sql = "${property.column.escapedName?j_string} ='" + value + "'";
    return getWhereClause();
    }
    
    <@columnfooter property=property/>
</#macro>

<#macro CharacterColumn property>
    <@columnheader property=property/>
    
    @Override
    public void set(final PreparedStatement preparedStatement, final int i, final Character value) throws SQLException {
    preparedStatement.setString(i,value == null ? null : String.valueOf(value));
    }

    @Override
    public Character get(final ResultSet resultSet, final int i) throws SQLException {
        String charString = resultSet.getString(i);
        return charString == null ? null : charString.charAt(0);
    }

    public final WhereClause  eq(final String value) {
    sql = "${property.column.escapedName?j_string} ='" + value + "'";
    return getWhereClause();
    }

    public final WhereClause LIKE(final String value) {
    sql = "${property.column.escapedName?j_string} LIKE '" + value + "'";
    return getWhereClause();
    }
    <@columnfooter property=property/>
</#macro>


<#macro BooleanColumn property>
    <@columnheader property=property/>
    public void set(final PreparedStatement preparedStatement, final int i, final Boolean value) throws SQLException {
    <#if property.column.typeName == "bit" >
        PGobject bitObject = new PGobject();
        bitObject.setType("bit");
        bitObject.setValue(value == null || !value ? "0" : "1" );
        preparedStatement.setObject(i, bitObject);
    <#else>
        preparedStatement.setBoolean(i,value);
    </#if>
    
    }

    @Override
    public Boolean get(final ResultSet resultSet, final int i) throws SQLException {
        return resultSet.getBoolean(i);
    }

    public final WhereClause  eq(final Boolean value) {
    sql = "${property.column.escapedName?j_string} =" + value ;
    return getWhereClause();
    }
    <@columnfooter property=property/>
</#macro>


<#macro BitSetColumn property>
    <@columnheader property=property/>
    public void set(final PreparedStatement preparedStatement, final int i, final BitSet value) throws SQLException {

        if(value != null) {
            PGobject bitObject = new PGobject();
            bitObject.setType("bit");
            StringBuffer valueBuffer = new StringBuffer();
            for (int j=0;j< value.length();j++) {
                valueBuffer.append(value.get(j)==true?"1":"0");
            }
            bitObject.setValue(valueBuffer.toString());
            preparedStatement.setObject(i, bitObject);
        }
    
    
    }

    public BitSet get(final ResultSet rs,final int index) throws SQLException {
        String jsonText = rs.getString(index);
        return jsonText == null ? null : BitSet.valueOf(jsonText.getBytes());
    }
    public final WhereClause  eq(final BitSet value) {
    sql = "${property.column.escapedName?j_string} =" + value ;
    return getWhereClause();
    }
    <@columnfooter property=property/>
</#macro>

<#macro numbercolumn type property>

    public void set(final PreparedStatement preparedStatement, final int i, final ${type} value) throws SQLException {
    preparedStatement.set${type}(i,value);
    }

    @Override
    public ${type} get(final ResultSet resultSet, final int i) throws SQLException {
        return resultSet.get${type}(i);
    }

    public final WhereClause eq(final ${type} value) {
    sql = "${property.column.escapedName?j_string} =" + value;
    return getWhereClause();
    }

    public final WhereClause gt(final ${type} value) {
    sql = "${property.column.escapedName?j_string} >" + value;
    return getWhereClause();
    }

    public final WhereClause  gte(final ${type} value) {
    sql = "${property.column.escapedName?j_string} >=" + value;
    return getWhereClause();
    }

    public final WhereClause  lt(final ${type} value) {
    sql = "${property.column.escapedName?j_string} <" + value;
    return getWhereClause();
    }

    public final WhereClause  lte(final ${type} value) {
    sql = "${property.column.escapedName?j_string} <=" + value;
    return getWhereClause();
    }



</#macro>

<#macro LongColumn property>
    <@columnheader property=property/>

    <@numbercolumn type="Long" property=property/>

    <@columnfooter property=property/>
</#macro>

<#macro ShortColumn property>
    <@columnheader property=property/>

    <@numbercolumn type="Short" property=property/>

    <@columnfooter property=property/>
</#macro>


<#macro IntegerColumn property>
    <@columnheader property=property/>

    <@numbercolumn type="Integer" property=property/>

    <@columnfooter property=property/>
</#macro>

<#macro ByteColumn property>
    <@columnheader property=property/>

    <@numbercolumn type="Byte" property=property/>

    <@columnfooter property=property/>
</#macro>
<#macro DoubleColumn property>
    <@columnheader property=property/>

    <@numbercolumn type="Double" property=property/>

    <@columnfooter property=property/>
</#macro>
<#macro BigDecimalColumn property>
    <@columnheader property=property/>

    <@numbercolumn type="BigDecimal" property=property/>

    <@columnfooter property=property/>
</#macro>

<#macro FloatColumn property>
    <@columnheader property=property/>
    <@numbercolumn type="Float" property=property/>
    <@columnfooter property=property/>
</#macro>


<#macro LocalDateColumn property>
    <@columnheader property=property/>

    public void set(final PreparedStatement preparedStatement, final int i, final LocalDate value) throws SQLException {
    preparedStatement.setDate(i,value == null ? null : java.sql.Date.valueOf(value));
    }

    @Override
    public LocalDate get(final ResultSet resultSet, final int i) throws SQLException {
        return resultSet.getDate(i) == null ? null : resultSet.getDate(i).toLocalDate();
    }

    public final WhereClause  eq(final LocalDate value) {
    sql = "${property.column.escapedName?j_string} =" + value;
    return getWhereClause();
    }

    public final WhereClause  gt(final LocalDate value) {
    sql = "${property.column.escapedName?j_string} >" + value;
    return getWhereClause();
    }

    public final WhereClause  gte(final LocalDate value) {
    sql = "${property.column.escapedName?j_string} >=" + value;
    return getWhereClause();
    }

    public final WhereClause  lt(final LocalDate value) {
    sql = "${property.column.escapedName?j_string} <" + value;
    return getWhereClause();
    }

    public final WhereClause  lte(final LocalDate value) {
    sql = "${property.column.escapedName?j_string} <=" + value;
    return getWhereClause();
    }

    <@columnfooter property=property/>
</#macro>

<#macro LocalTimeColumn property>
    <@columnheader property=property/>

    public void set(final PreparedStatement preparedStatement, final int i, final LocalTime value) throws SQLException {
    preparedStatement.setTime(i,value == null ? null : java.sql.Time.valueOf(value));
    }

    @Override
    public LocalTime get(final ResultSet resultSet, final int i) throws SQLException {
        return resultSet.getTime(i) == null ? null : resultSet.getTime(i).toLocalTime();
    }
    public final WhereClause  eq(final LocalTime value) {
    sql = "${property.column.escapedName?j_string} =" + value;
    return getWhereClause();
    }

    public final WhereClause  gt(final LocalTime value) {
    sql = "${property.column.escapedName?j_string} >" + value;
    return getWhereClause();
    }

    public final WhereClause  gte(final LocalTime value) {
    sql = "${property.column.escapedName?j_string} >=" + value;
    return getWhereClause();
    }

    public final WhereClause  lt(final LocalTime value) {
    sql = "${property.column.escapedName?j_string} <" + value;
    return getWhereClause();
    }

    public final WhereClause  lte(final LocalTime value) {
    sql = "${property.column.escapedName?j_string} <=" + value;
    return getWhereClause();
    }


    <@columnfooter property=property/>
</#macro>

<#macro LocalDateTimeColumn property>
    <@columnheader property=property/>

    public void set(final PreparedStatement preparedStatement, final int i, final LocalDateTime value) throws SQLException {
    preparedStatement.setTimestamp(i,value == null ? null : java.sql.Timestamp.valueOf(value));
    }

    public final WhereClause  eq(final LocalDateTime value) {
    sql = "${property.column.escapedName?j_string} =" + value;
    return getWhereClause();
    }

    public final WhereClause  gt(final LocalDateTime value) {
    sql = "${property.column.escapedName?j_string} >" + value;
    return getWhereClause();
    }

    public final WhereClause  gte(final LocalDateTime value) {
    sql = "${property.column.escapedName?j_string} >=" + value;
    return getWhereClause();
    }

    public final WhereClause  lt(final LocalDateTime value) {
    sql = "${property.column.escapedName?j_string} <" + value;
    return getWhereClause();
    }

    public final WhereClause  lte(final LocalDateTime value) {
    sql = "${property.column.escapedName?j_string} <=" + value;
    return getWhereClause();
    }

    <@columnfooter property=property/>
</#macro>


<#macro BoxColumn property>
<@columnheader property=property/>
 
    public void set(final PreparedStatement preparedStatement, final int i, final Envelope value) throws SQLException {
    preparedStatement.setObject(i,convertBox(value),java.sql.Types.OTHER);
    }

    public Envelope get(final ResultSet rs,final int index) throws SQLException {
        PGbox pGbox = (PGbox) rs.getObject(index);
        return pGbox == null ? null : new Envelope(pGbox.point[0].x,pGbox.point[1].x,pGbox.point[0].y,pGbox.point[1].y);
    }

    <@columnfooter property=property/>
</#macro>
 
 
<#macro PointColumn property>
    <@columnheader property=property/>

    public void set(final PreparedStatement preparedStatement, final int i, final Point value) throws SQLException {
    preparedStatement.setObject(i,convertPoint(value),java.sql.Types.OTHER);
    }

    public Point get(final ResultSet rs,final int index) throws SQLException {
        PGpoint pGpoint = (PGpoint) rs.getObject(index);
        return pGpoint == null ? null : new GeometryFactory().createPoint(new Coordinate(pGpoint.x,pGpoint.y));
    }



    <@columnfooter property=property/>
</#macro>


<#macro LineSegmentColumn property>
    <@columnheader property=property/>
    public void set(final PreparedStatement preparedStatement, final int i, final LineSegment value) throws SQLException {
    preparedStatement.setObject(i,convertLseg(value));
    }

    public LineSegment get(final ResultSet rs,final int index) throws SQLException {
        PGlseg pGlseg = (PGlseg) rs.getObject(index);
        return pGlseg == null ? null : new LineSegment(pGlseg.point[0].x,pGlseg.point[0].y,pGlseg.point[1].x,pGlseg.point[1].y);
    }
    
    <@columnfooter property=property/>
</#macro>

<#macro InetAddressColumn property>
    <@columnheader property=property/>
     public void set(final PreparedStatement preparedStatement, final int i, final  InetAddress value) throws SQLException {
    
     preparedStatement.setObject(i,convertInet(value));
    }
    public InetAddress get(final ResultSet rs,final int index) throws SQLException {
    String addressText = rs.getString(index);
    if(addressText == null) {
        return null;
    }
        try {
            return InetAddress.getByName(addressText);
        } catch (UnknownHostException e) {
            throw new SQLException(e);
        }
    }

    <@columnfooter property=property/>
</#macro>

<#macro CidrColumn property>
    <@columnheader property=property/>
     public void set(final PreparedStatement preparedStatement, final int i, final SubnetUtils value) throws SQLException {
    
     preparedStatement.setObject(i,convertCidr(value));
    }

    public SubnetUtils get(final ResultSet rs,final int index) throws SQLException {
    String cidrAddress = rs.getString(index);
    return cidrAddress == null ? null : new SubnetUtils(cidrAddress);
    }
    

    <@columnfooter property=property/>
</#macro>

<#macro CircleColumn property>
    <@columnheader property=property/>
     public void set(final PreparedStatement preparedStatement, final int i, final Circle value) throws SQLException {
    
     preparedStatement.setObject(i,convertCircle(value));
    }

    public Circle get(final ResultSet rs,final int index) throws SQLException {

        PGcircle pGcircle = (PGcircle) rs.getObject(index);
          if(pGcircle == null) {
            return null;
        }
        PGpoint centerPoint = pGcircle.center;
        double radius = pGcircle.radius;
        return SpatialContext.GEO.makeCircle(centerPoint.x, centerPoint.y, radius);

    }


    <@columnfooter property=property/>
</#macro>

<#macro LineColumn property>
    <@columnheader property=property/>
     public void set(final PreparedStatement preparedStatement, final int i, final LineString value) throws SQLException {
    
     preparedStatement.setObject(i,convertLine(value));
    }

    private static Coordinate calculateStartPoint(double a, double b, double c) {
        double startX = 0; // Define the x-coordinate for the start point
        double startY = (-c - a * startX) / b; // Calculate the corresponding y-coordinate
        return new Coordinate(startX, startY);
    }

    private static Coordinate calculateEndPoint(double a, double b, double c) {
        double endX = 1; // Define the x-coordinate for the end point
        double endY = (-c - a * endX) / b; // Calculate the corresponding y-coordinate
        return new Coordinate(endX, endY);
    }
    
public LineString get(final ResultSet rs,final int index) throws SQLException {
        PGline pGline = (PGline) rs.getObject(index);
        if(pGline == null) {
            return null;
        }
            double a = pGline.a;
            double b = pGline.b;
            double c = pGline.c;

            Coordinate startPoint = calculateStartPoint(a, b, c);
            Coordinate endPoint = calculateEndPoint(a, b, c);

            Coordinate[] coordinates = new Coordinate[]{
                    startPoint, endPoint
            };

            GeometryFactory geometryFactory = new GeometryFactory();
        return geometryFactory.createLineString(coordinates);
    }
    
    <@columnfooter property=property/>
</#macro>
<#macro PolygonColumn property>
    <@columnheader property=property/>
     public void set(final PreparedStatement preparedStatement, final int i, final Polygon value) throws SQLException {
    
     preparedStatement.setObject(i,convertPolygon(value));
    }

    public Polygon get(final ResultSet rs,final int index) throws SQLException {
        PGpolygon pgPolygon = (PGpolygon) rs.getObject(index);
          if(pgPolygon == null) {
            return null;
        }
        Coordinate[] coordinates = new Coordinate[pgPolygon.points.length + 1];
                for (int i = 0; i < pgPolygon.points.length; i++) {
                    org.postgresql.geometric.PGpoint point = pgPolygon.points[i];
                    coordinates[i] = new Coordinate(point.x, point.y);
                }
        // Close the ring by adding the first point at the end
        coordinates[pgPolygon.points.length] = coordinates[0];
        GeometryFactory factory = new GeometryFactory();
        LinearRing ring = factory.createLinearRing(coordinates);
        return factory.createPolygon(ring, null);
    }
    <@columnfooter property=property/>
</#macro>