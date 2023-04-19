CREATE TABLE [Logging].[LogSettings] (
    [LoggingObject] NVARCHAR (257) NOT NULL,
    [LoggingLevel]  NVARCHAR (13)  NULL,
    CONSTRAINT [PK_LogSettings] PRIMARY KEY CLUSTERED ([LoggingObject] ASC)
);

