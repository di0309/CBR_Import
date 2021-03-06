USE [CBR]
GO
/****** Object:  StoredProcedure [dbo].[ImportData]    Script Date: 12.05.2020 23:23:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Не вполне понятна предметная область, что постоянно, а что меняется и как друг с другом соотносится. 
--Но, поскльку это тестовое задание, а не работа, принимаем следующие допущения:
--Одному BIC в любое время соответствуют один и тот же UID, Account и тд. Они постоянны и не меняются. В каждом случае связь один ко многим.
CREATE PROCEDURE [dbo].[ImportData] 
	@XML xml
	
AS
SET XACT_ABORT, NOCOUNT ON
BEGIN TRY
BEGIN TRANSACTION 
SET NOCOUNT ON;

	DECLARE @x XML

	CREATE TABLE #BIC(
	[BIC] [nvarchar](100) NOT NULL,
	[ChangeType] [nvarchar](100) NULL)

	CREATE TABLE #Participant(
	[BIC] [nvarchar](100) NOT NULL,
	[ParticipantStatus] [nvarchar](100) NULL,
	[UID] [nvarchar](100) NOT NULL,
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
	[NameP] [nvarchar](1000) NULL)

	CREATE TABLE #Rstr(
	[UID] [nvarchar](100) NOT NULL,
	[RstrDate] [date] NULL,
	[Rstr] [nvarchar](100) NULL)

	CREATE TABLE #Acc(
	[BIC] [nvarchar](100) NOT NULL,
	[DateIn] [date] NULL,
	[AccountStatus] [nvarchar](100) NULL,
	[AccountCBRBIC] [nvarchar](100) NULL,
	[CK] [nvarchar](100) NULL,
	[RegulationAccountType] [nvarchar](100) NULL,
	[Account] [nvarchar](100) NOT NULL)

	CREATE TABLE #AccRstr(
	[Account] [nvarchar](100) NOT NULL,
	[AccRstrDate] [date] NULL,
	[AccRstr] [nvarchar](100) NULL)

	CREATE TABLE #SW(
	[BIC] [nvarchar](100) NOT NULL,
	[DefaultSWBIC] [nvarchar](100) NULL,
	[SWBIC] [nvarchar](100) NULL)
	
	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	INSERT INTO #BIC
	SELECT 
		   t.node.value('@BIC', 'NVARCHAR(100)'),
		   t.node.value('@ChangeType', 'NVARCHAR(100)')
	FROM @XML.nodes('ED807/BICDirectoryEntry') t(node)

	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	INSERT INTO #Participant
	SELECT
		   t.node.value('@BIC', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@ParticipantStatus)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@UID)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@XchType)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@Srvcs)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@PtType)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@DateOut)[1]', 'DATE'),
		   t.node.value('(./ParticipantInfo/@DateIn)[1]', 'DATE'),
		   t.node.value('(./ParticipantInfo/@PrntBIC)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@Adr)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@Nnp)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@Tnp)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@Ind)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@Rgn)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@CntrCd)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@RegN)[1]', 'NVARCHAR(100)'),
		   t.node.value('(./ParticipantInfo/@EnglName)[1]', 'NVARCHAR(1000)'),
		   t.node.value('(./ParticipantInfo/@NameP)[1]', 'NVARCHAR(1000)')
	FROM @XML.nodes('ED807/BICDirectoryEntry') t(node)

	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	INSERT INTO #SW
	SELECT BIC, DefaultSWBIC, SWBIC
	FROM (
	SELECT
		   t.node.value('@BIC', 'NVARCHAR(100)') as BIC,
		   t.node.value('(./SWBICS/@DefaultSWBIC)[1]', 'NVARCHAR(100)') as DefaultSWBIC,
		   t.node.value('(./SWBICS/@SWBIC)[1]', 'NVARCHAR(100)') as SWBIC
	FROM @XML.nodes('ED807/BICDirectoryEntry') t(node) ) as t
	WHERE DefaultSWBIC IS NOT NULL AND SWBIC IS NOT NULL

	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	SELECT @x = @XML.query(' 
	   for $BIC in /ED807/BICDirectoryEntry,  
		   $acc in $BIC/Accounts
	   return   
		   (<Acc BIC = "{data($BIC/@BIC)}" DateIn = "{data($acc/@DateIn)}" AccountStatus = "{data($acc/@AccountStatus)}" 
		   AccountCBRBIC = "{data($acc/@AccountCBRBIC)}" CK = "{data($acc/@CK)}" RegulationAccountType = "{data($acc/@RegulationAccountType)}"
		   Account = "{data($acc/@Account)}" ></Acc>)') 
	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	INSERT INTO #Acc
	SELECT 
		   t.node.value('@BIC', 'NVARCHAR(100)'),
		   t.node.value('@DateIn', 'DATE'),
		   t.node.value('@AccountStatus', 'NVARCHAR(100)'),
		   t.node.value('@AccountCBRBIC', 'NVARCHAR(100)'),
		   t.node.value('@CK', 'NVARCHAR(100)'),
		   t.node.value('@RegulationAccountType', 'NVARCHAR(100)'),
		   t.node.value('@Account', 'NVARCHAR(100)')
	FROM @x.nodes('Acc') t(node)
	
	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	SELECT @x = @XML.query('  
	   for $BIC in /ED807/BICDirectoryEntry,  
		   $acc in $BIC/Accounts,
		   $accRstr in $acc/AccRstrList
	   return   
		   (<AccRstr Account = "{data($acc/@Account)}"  AccRstrDate = "{data($accRstr/@AccRstrDate)}" AccRstr = "{data($accRstr/@AccRstr)}" ></AccRstr>)')  
	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	INSERT INTO #AccRstr
	SELECT 
		   t.node.value('@Account', 'NVARCHAR(100)'),
		   t.node.value('@AccRstrDate', 'DATE'),
		   t.node.value('@AccRstr', 'NVARCHAR(100)')
	FROM @x.nodes('AccRstr') t(node)
	
	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	SELECT @x = @XML.query(' 
	   for $BIC in /ED807/BICDirectoryEntry,  
		   $part in $BIC/ParticipantInfo,
		   $rstr in $part/RstrList
	   return   
		   (<RstrList UID = "{data($part/@UID)}"  RstrDate = "{data($rstr/@RstrDate)}" Rstr = "{data($rstr/@Rstr)}" ></RstrList>)') 
	;WITH XMLNAMESPACES(DEFAULT 'urn:cbr-ru:ed:v2.0')
	INSERT INTO #Rstr
	SELECT 
		   t.node.value('@UID', 'NVARCHAR(100)'),
		   t.node.value('@RstrDate', 'DATE'),
		   t.node.value('@Rstr', 'NVARCHAR(100)')
	FROM @x.nodes('RstrList') t(node)

	--[dbo].[BICDirectoryEntry]
	UPDATE [dbo].[BICDirectoryEntry]
	SET [ChangeType] = b.ChangeType,
		[update_date] = GETDATE()
	FROM #BIC as b
	INNER JOIN [dbo].[BICDirectoryEntry] as bde
	ON b.BIC = bde.BIC
	WHERE b.ChangeType <> ISNULL(bde.ChangeType, '')

	INSERT [dbo].[BICDirectoryEntry] ([BIC], [ChangeType], [insert_date])
	SELECT	b.BIC, b.ChangeType, GETDATE()
	FROM #BIC as b
	LEFT JOIN [dbo].[BICDirectoryEntry] as bde
	ON b.BIC = bde.BIC
	WHERE bde.BIC IS NULL

	--[dbo].[SWBICS]
	UPDATE [dbo].[SWBICS]
	SET [DefaultSWBIC] = s.DefaultSWBIC, 
		[SWBIC] = s.SWBIC,
		[update_date] = GETDATE()
	FROM #SW as s
	INNER JOIN [dbo].[BICDirectoryEntry] as b
	ON s.BIC = b.BIC
	INNER JOIN [dbo].[SWBICS] as swbics
	ON b.id = swbics.bic_id
	WHERE s.[DefaultSWBIC] <> swbics.DefaultSWBIC OR s.SWBIC <> swbics.SWBIC

	INSERT INTO [dbo].[SWBICS] ([bic_id], [DefaultSWBIC], [SWBIC], [insert_date])
	SELECT b.[id], s.[DefaultSWBIC], s.[SWBIC], GETDATE()
	FROM #SW as s
	INNER JOIN [dbo].[BICDirectoryEntry] as b
	ON s.BIC = b.BIC
	LEFT JOIN [dbo].[SWBICS] as swbics
	ON b.id = swbics.bic_id
	WHERE swbics.DefaultSWBIC IS NULL

	--[dbo].[ParticipantInfo]
	UPDATE [dbo].[ParticipantInfo]
	SET [ParticipantStatus] = p.ParticipantStatus,
		[XchType] = p.[XchType],
		[Srvcs] = p.[Srvcs],
		[PtType] = p.[PtType],
		[DateOut] = p.[DateOut],
		[DateIn] = p.[DateIn],
		[PrntBIC] = p.[PrntBIC],
		[Adr] = p.[Adr],
		[Nnp] = p.[Nnp],
		[Tnp] = p.[Tnp],
		[Ind] = p.[Ind],
		[Rgn] = p.[Rgn],
		[CntrCd] = p.[CntrCd],
		[RegN] = p.[RegN],
		[EnglName] = p.[EnglName],
		[NameP] = p.[NameP]
	FROM #Participant as p
	INNER JOIN [dbo].[ParticipantInfo] as part
	ON p.[UID] = part.[UID]

	INSERT INTO [dbo].[ParticipantInfo]
	SELECT 
		b.id
		,P.[ParticipantStatus]
		,P.[UID]
		,P.[XchType] 
		,P.[Srvcs] 
		,P.[PtType] 
		,P.[DateOut] 
		,P.[DateIn] 
		,P.[PrntBIC] 
		,P.[Adr] 
		,P.[Nnp] 
		,P.[Tnp] 
		,P.[Ind] 
		,P.[Rgn] 
		,P.[CntrCd] 
		,P.[RegN] 
		,P.[EnglName] 
		,P.[NameP] 
	FROM #Participant as p
	INNER JOIN [dbo].[BICDirectoryEntry] as b
	ON p.BIC = b.BIC
	LEFT JOIN [dbo].[ParticipantInfo] as part
	ON b.id = part.bic_id
	WHERE part.bic_id IS NULL

	--[dbo].[RstrList]
	UPDATE [dbo].[RstrList]
	SET	[RstrDate] = r.RstrDate,
		[Rstr] = r.Rstr
	FROM #Rstr as r
	INNER JOIN [dbo].[ParticipantInfo] as p
	ON r.[UID] = p.[UID]
	INNER JOIN [dbo].[RstrList] as rstr
	ON p.id = rstr.Participant_id

	INSERT INTO [dbo].[RstrList]
	SELECT p.id, r.RstrDate, r.Rstr
	FROM #Rstr as r
	INNER JOIN [dbo].[ParticipantInfo] as p
	ON r.[UID] = p.[UID]
	LEFT JOIN [dbo].[RstrList] as rstr
	ON p.id = rstr.Participant_id
	WHERE rstr.Participant_id IS NULL

	--[dbo].[Accounts]
	UPDATE [dbo].[Accounts]
	SET	[DateIn] = a.DateIn,
		[AccountStatus] = a.AccountStatus,
		[AccountCBRBIC] = a.AccountCBRBIC,
		[CK] = a.CK,
		[RegulationAccountType] = a.RegulationAccountType
	FROM #Acc as a
	INNER JOIN [dbo].[Accounts] as acc
	ON a.Account = acc.Account

	INSERT INTO [dbo].[Accounts]
	SELECT b.id, a.DateIn, a.AccountStatus, a.AccountCBRBIC, a.CK, a.RegulationAccountType, a.Account
	FROM #Acc as a
	INNER JOIN [dbo].[BICDirectoryEntry] as b
	ON a.BIC = b.BIC
	LEFT JOIN [dbo].[Accounts] as acc
	ON a.Account = acc.Account
	WHERE acc.Account IS NULL

	--[dbo].[AccRstrList]
	UPDATE [dbo].[AccRstrList]
	SET	[AccRstrDate] = a.AccRstrDate,
		[AccRstr] = a.AccRstr
	FROM #AccRstr as a
	INNER JOIN [dbo].[Accounts] as acc
	ON a.Account = acc.Account
	INNER JOIN [dbo].[AccRstrList] as arl
	ON acc.id = arl.id_account

	INSERT INTO [dbo].[AccRstrList]
	SELECT a.AccRstrDate, a.AccRstr, acc.id
	FROM #AccRstr as a
	INNER JOIN [dbo].[Accounts] as acc
	ON a.Account = acc.Account
	LEFT JOIN [dbo].[AccRstrList] as arl
	ON acc.id = arl.id_account
	WHERE arl.id_account IS NULL

COMMIT
END TRY
BEGIN CATCH
      IF @@trancount > 0 ROLLBACK TRANSACTION
      DECLARE @msg nvarchar(2048) = error_message()  
      RAISERROR (@msg, 16, 1)
	  --вызываем процедуру записи логов
      RETURN -1
END CATCH
