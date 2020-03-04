
CREATE TABLE dbo.TablesToCopy(
	SchemaName varchar(128) NOT NULL,
	TableName varchar(128) NOT NULL,
	TableType varchar(4) NULL,
	SelectProcedure varchar(128) NULL,
	UpsertProcedure varchar(128) NULL,
	LoadFrequency varchar(20) NULL CONSTRAINT CK_TablesToCopy_LoadFrequency CHECK  ((LoadFrequency='Hourly' OR LoadFrequency='Daily')),
	StagedDateTime datetime2(0) NULL,
	CompletedDateTime datetime2(7) NULL
) 
GO

CREATE   PROCEDURE dbo.TablesToCopy_Get
(
	@LoadFrequency VARCHAR(20)
)
AS 
BEGIN

	SELECT 
		SchemaName,
		TableName,
		SchemaName + '.' + TableName AS SourceTable, 
		'staging.' + SchemaName + '_' + TableName AS DestTable, 
		TableType,
		SchemaName + '.' + SelectProcedure AS SelectProcedure,
		'staging.' + SchemaName + '_' + UpsertProcedure AS UpsertProcedure,
		StagedDateTime,
		CompletedDateTime
	FROM TablesToCopy
	WHERE LoadFrequency = @LoadFrequency;
END
GO


CREATE PROCEDURE dbo.UpdateCompletedDateTime
(
	@SchemaName VARCHAR(128),
	@TableName VARCHAR(128),
	@StagedDateTime DATETIME2(0),
	@CompletedDateTime DATETIME2(0)
)
AS
BEGIN
	-- ONLY UPDATE ROWS WHERE STAGING WAS SUCCESSFUL
	UPDATE dbo.TablesToCopy
	SET CompletedDateTime = @CompletedDateTime
	WHERE SchemaName = @SchemaName 
	AND TableName = @TableName
	AND StagedDateTime = @StagedDateTime;
END
GO


CREATE PROCEDURE dbo.UpdateStagedDateTime
(
	@SchemaName VARCHAR(128),
	@TableName VARCHAR(128),
	@StagedDateTime DATETIME2(0)
)
AS
BEGIN
	UPDATE dbo.TablesToCopy
	SET	StagedDateTime = @StagedDateTime
	WHERE SchemaName = @SchemaName 
	AND TableName = @TableName;
END
GO
