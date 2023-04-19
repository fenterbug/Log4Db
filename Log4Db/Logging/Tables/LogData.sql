CREATE TABLE [Logging].[LogData] (
    [User]          NVARCHAR (128)     NULL,
    [Object]        NVARCHAR (257)     NULL,
    [LineNumber]    INT                NULL,
    [Host]          NVARCHAR (128)     NULL,
    [App]           NVARCHAR (128)     NULL,
    [LogDate]       DATETIMEOFFSET (7) NULL,
    [State]         INT                NULL,
    [Severity]      INT                NULL,
    [ErrorNumber]   INT                NULL,
    [Message]       NVARCHAR (MAX)     NULL,
    [SystemMessage] NVARCHAR (MAX)     NULL
);

