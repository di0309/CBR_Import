USE [CBR]
GO

/****** Object:  Table [dbo].[BICDirectoryEntry]    Script Date: 12.05.2020 19:23:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BICDirectoryEntry](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[BIC] [nvarchar](100) NOT NULL,
	[ChangeType] [nvarchar](100) NULL,
	[insert_date] [datetime] NULL,
	[update_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

CREATE TABLE [dbo].[ParticipantInfo](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bic_id] [int] NOT NULL,
	[ParticipantStatus] [nvarchar](100) NULL,
	[UID] [nvarchar](100) NULL,
	[XchType] [nvarchar](100) NULL,
	[Srvcs] [nvarchar](100) NULL,
	[PtType] [nvarchar](100) NULL,
	[DateOut] [date] NULL,
	[DateIn] [date] NULL,
	[PrntBIC] [nvarchar](100) NULL,
	[Adr] [nvarchar](100) NULL,
	[Nnp] [nvarchar](100) NULL,
	[Tnp] [nvarchar](100) NULL,
	[Ind] [nvarchar](100) NULL,
	[Rgn] [nvarchar](100) NULL,
	[CntrCd] [nvarchar](100) NULL,
	[RegN] [nvarchar](100) NULL,
	[EnglName] [nvarchar](1000) NULL,
	[NameP] [nvarchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ParticipantInfo]  WITH CHECK ADD  CONSTRAINT [FK_ParticipantInfo_BICDirectoryEntry] FOREIGN KEY([bic_id])
REFERENCES [dbo].[BICDirectoryEntry] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[ParticipantInfo] CHECK CONSTRAINT [FK_ParticipantInfo_BICDirectoryEntry]
GO

CREATE TABLE [dbo].[Accounts](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bic_id] [int] NOT NULL,
	[DateIn] [date] NULL,
	[AccountStatus] [nvarchar](100) NULL,
	[AccountCBRBIC] [nvarchar](100) NULL,
	[CK] [nvarchar](100) NULL,
	[RegulationAccountType] [nvarchar](100) NULL,
	[Account] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Accounts]  WITH CHECK ADD  CONSTRAINT [FK_Accounts_BICDirectoryEntry] FOREIGN KEY([bic_id])
REFERENCES [dbo].[BICDirectoryEntry] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Accounts] CHECK CONSTRAINT [FK_Accounts_BICDirectoryEntry]
GO

CREATE TABLE [dbo].[RstrList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Participant_id] [int] NOT NULL,
	[RstrDate] [date] NULL,
	[Rstr] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[RstrList]  WITH CHECK ADD  CONSTRAINT [FK_RstrList_ParticipantInfo] FOREIGN KEY([Participant_id])
REFERENCES [dbo].[ParticipantInfo] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[RstrList] CHECK CONSTRAINT [FK_RstrList_ParticipantInfo]
GO


CREATE TABLE [dbo].[AccRstrList](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AccRstrDate] [date] NULL,
	[AccRstr] [nvarchar](100) NULL,
	[id_account] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AccRstrList]  WITH CHECK ADD  CONSTRAINT [FK_AccRstrList_Accounts] FOREIGN KEY([id_account])
REFERENCES [dbo].[Accounts] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[AccRstrList] CHECK CONSTRAINT [FK_AccRstrList_Accounts]
GO


CREATE TABLE [dbo].[SWBICS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[bic_id] [int] NOT NULL,
	[DefaultSWBIC] [nvarchar](100) NULL,
	[SWBIC] [nvarchar](100) NULL,
	[insert_date] [datetime] NULL,
	[update_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[SWBICS]  WITH CHECK ADD  CONSTRAINT [FK_SWBICS_BICDirectoryEntry] FOREIGN KEY([bic_id])
REFERENCES [dbo].[BICDirectoryEntry] ([id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[SWBICS] CHECK CONSTRAINT [FK_SWBICS_BICDirectoryEntry]
GO

