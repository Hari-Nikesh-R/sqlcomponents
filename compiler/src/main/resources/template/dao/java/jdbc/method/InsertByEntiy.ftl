<#if table.tableType == 'TABLE' >
	public final int insert(final ${name} ${name?uncap_first}) throws SQLException  {
		final String query = """
		INSERT INTO ${table.escapedName} (
		<#assign index=0>
		<#list insertableProperties as property>
			<#if index == 0><#assign index=1><#else>,</#if>${property.column.escapedName}
		</#list>
		)	     
	    VALUES (
	    <#assign index=0>
	    <#list insertableProperties as property>

			<#if index == 0><#if sequenceName?? && table.highestPKIndex == 1>
			<#list properties as property>
			    <#if property.column.primaryKeyIndex == 1>nextval('${sequenceName}')</#if>
			 </#list>
			 <#else>    ?</#if><#assign index=1><#else>            ,?</#if>

		</#list>
	    )	
		""";

		try (Connection conn = dataSource.getConnection();
             PreparedStatement preparedStatement = conn.prepareStatement(query))
        {
			<#assign index=0>
			<#assign column_index=1>
			<#list insertableProperties as property>
			<#if index == 0>
				<#if sequenceName?? && property.column.primaryKeyIndex == 1>
				<#else>
				preparedStatement.set${getJDBCClassName(property.dataType)}(${column_index},${wrapGet(name?uncap_first,property)});
				<#assign column_index = column_index + 1>
				</#if>
			<#assign index=1>
			<#else>
			preparedStatement.set${getJDBCClassName(property.dataType)}(${column_index},${wrapGet(name?uncap_first,property)});
			<#assign column_index = column_index + 1>
			</#if>

			</#list>	
			return preparedStatement.executeUpdate();
        }
	}<#assign a=addImportStatement(beanPackage+"."+name)><#assign a=addImportStatement("java.sql.PreparedStatement")>
</#if>