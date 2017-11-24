SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'SCM.ObjectLog' AND type = 'U')
BEGIN
    DROP TABLE [dbo].[SCM.ObjectLog]
END
GO

CREATE TABLE [dbo].[SCM.ObjectLog](
	[timestamp] [timestamp] NOT NULL,
	[Object Type] [int] NOT NULL,
	[Object ID] [int] NOT NULL,
	[Initial Block DateTime] [datetime] NOT NULL,
	[Last Block DateTime] [datetime] NOT NULL,
	[Object Last Name] [varchar](30) NOT NULL,
	[Object Last Version List] [varchar](80) NOT NULL,
	[Object Last Object Date] [datetime] NOT NULL,
	[Object Last Object Time] [datetime] NOT NULL,
	[Last Action] [int] NOT NULL,
	[Action GUID] [varchar](60) NOT NULL,
	--[Delete Permited] [tinyint] NOT NULL,
 CONSTRAINT [SCM.ObjectLog$0] PRIMARY KEY CLUSTERED
(
	[Object Type] ASC,
	[Object ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


