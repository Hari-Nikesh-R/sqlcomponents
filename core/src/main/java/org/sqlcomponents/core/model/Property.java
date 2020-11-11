package org.sqlcomponents.core.model;

import org.sqlcomponents.core.model.relational.Column;
import org.sqlcomponents.core.model.relational.Key;

import java.util.SortedSet;

public class Property  {

	
	public Property(Column column) {
		setColumn(column) ;
	}
	
	private Column column ;
		
	private String name ;	
	
	private String dataType;
	
	private String uniqueConstraintGroup ;

	public String getUniqueConstraintGroup() {
		return uniqueConstraintGroup;
	}

	public void setUniqueConstraintGroup(String uniqueConstraintGroup) {
		this.uniqueConstraintGroup = uniqueConstraintGroup;
	}

	public Column getColumn() {
		return column;
	}

	public void setColumn(Column column) {
		this.column = column;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}


	
}
