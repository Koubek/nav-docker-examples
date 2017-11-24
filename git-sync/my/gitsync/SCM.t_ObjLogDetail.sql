SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'SCM.ObjectLogDetail' AND type = 'U')
BEGIN
    DROP TABLE [dbo].[SCM.ObjectLogDetail]
END
GO

CREATE TABLE [dbo].[SCM.ObjectLogDetail](
	[Object Type] [int] NOT NULL,
	[Object ID] [int] NOT NULL,
	[Modification DateTime] [datetime] NOT NULL,
	[Object Name] [varchar](30) NOT NULL,
	[Object BLOB Content] [image] NULL,
	[Object TXT Content] [image] NULL,
	[Operation Type] [int] NOT NULL,
	[Object Version List] [varchar](80) NOT NULL,
	[Object Modified] [tinyint] NOT NULL,
	[Object Compiled] [tinyint] NOT NULL,
	[Object Date] [datetime] NOT NULL,
	[Object Time] [datetime] NOT NULL,
 CONSTRAINT [SCM.ObjectLogDetail$0] PRIMARY KEY CLUSTERED
(
	[Object Type] ASC,
	[Object ID] ASC,
	[Modification DateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


