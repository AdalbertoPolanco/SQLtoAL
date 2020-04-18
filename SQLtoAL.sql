/*
TableName : Table Real Name
TableDesc : Name used on Caption
TableID   :  BC Table ID
*/

		declare  @TableName as varchar(50)='{Table Name}'
		DECLARE @TableDesc VARCHAR(100)='{Table Description}'
		DECLARE @TableID VARCHAR(10) ='{Table ID}'
        --AS 
                
        -- creation of variables 
        DECLARE @strToPrint as varchar(4000)
 
        DECLARE @ColumnName as varchar(300)
 DECLARE @Key VARCHAR(2000)=''
        DECLARE @AlternateType as int
 
        DECLARE @ColumnLength as int
 
        DECLARE @ColumnPrecision as int
 
        DECLARE @ColumnScale as int
 
        DECLARE @TypeName as varchar(30)
 PRINT 'table 50042 "'+@TableDesc+'"
{
    Caption = '''+@TableDesc+''';
    DataClassification = ToBeClassified;

    fields
    {
	'

        
        DECLARE curColumns cursor READ_ONLY FORWARD_ONLY for


SELECT
	 c.name AS ColumnName,
	CASE
		WHEN t.name IN ('char', 'varchar', 'binary', 'varbinary', 'nchar', 'nvarchar') AND ISNULL(PK.CONSTRAINT_NAME,'')<>''  THEN 1
		WHEN t.name IN ('char', 'varchar', 'binary', 'varbinary', 'nchar', 'nvarchar') AND ISNULL(PK.CONSTRAINT_NAME,'')=''  THEN 10
		WHEN t.name IN ('decimal', 'numeric','int') AND  ISNULL(PK.CONSTRAINT_NAME,'')<>'' THEN 2
		WHEN t.name IN ('decimal', 'numeric','int') AND  ISNULL(PK.CONSTRAINT_NAME,'')='' THEN 20
		ELSE 0
	END AS AlternateType,
	c.length AS ColumnLength,
	c.prec AS ColumnPrecision,
	c.scale AS ColumnScale,
	t.name AS TypeName
	
FROM syscolumns c
INNER JOIN systypes t
	ON c.xtype = t.xtype
	AND c.usertype = t.usertype
	INNER JOIN sysobjects o ON c.id=o.id

LEFT OUTER JOIN
(SELECT  K.TABLE_NAME ,
    K.COLUMN_NAME ,
    K.CONSTRAINT_NAME
FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS C
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS K ON C.TABLE_NAME = K.TABLE_NAME
                                                         AND C.CONSTRAINT_CATALOG = K.CONSTRAINT_CATALOG
                                                         AND C.CONSTRAINT_SCHEMA = K.CONSTRAINT_SCHEMA
                                                         AND C.CONSTRAINT_NAME = K.CONSTRAINT_NAME
WHERE   C.CONSTRAINT_TYPE = 'PRIMARY KEY'
) PK ON  PK.TABLE_NAME=O.name AND PK.COLUMN_NAME=C.NAME
WHERE c.id = OBJECT_ID(N'' + @TABLENAME + '')
ORDER BY c.colid


OPEN curColumns
FETCH NEXT FROM curColumns INTO
@COLUMNNAME
, @ALTERNATETYPE
, @COLUMNLENGTH
, @COLUMNPRECISION
, @COLUMNSCALE
, @TYPENAME

WHILE (@@FETCH_STATUS = 0) BEGIN
DECLARE @Tipo VARCHAR(30)
SET @STRTOPRINT = @COLUMNNAME
IF @ALTERNATETYPE = 1 BEGIN
SET @Tipo= ' ;Code[' + CAST(@COLUMNLENGTH AS varchar) + '])'
SET @Key = @Key+CASE WHEN @Key='' THEN '"'+@ColumnName+'"' ELSE ','+ '"'+@ColumnName+'"' end
END
IF @ALTERNATETYPE = 10 BEGIN
SET @Tipo= ' ;Text[' + CAST(@COLUMNLENGTH AS varchar) + '])'
END
IF @ALTERNATETYPE = 2 BEGIN
SET @Tipo= ' ; Decimal'
SET @Key = @Key+ CASE WHEN @Key='' THEN '"'+@ColumnName+'"' ELSE ','+ '"'+@ColumnName+'"' end
END
IF  @AlternateType=20 BEGIN
SET @Tipo= ' ; Decimal'
END

IF @ALTERNATETYPE = 0 BEGIN
SET @Tipo= ' Type Error'
END
SET @STRTOPRINT = '        field(1; "'+@COLUMNNAME+'"; '+ @Tipo +'
        {
            Caption = '''+REPLACE(@COLUMNNAME,'_',' ')  +''';
            DataClassification = ToBeClassified;
        }
'

PRINT @STRTOPRINT

FETCH NEXT FROM curColumns INTO
@COLUMNNAME
, @ALTERNATETYPE
, @COLUMNLENGTH
, @COLUMNPRECISION
, @COLUMNSCALE
, @TYPENAME

END

CLOSE curColumns
DEALLOCATE curColumns
IF @Key<>''
PRINT '
    keys
    {
        key(PK; '+ @Key+')
        {
            Clustered = true;
        }
    }

}'




