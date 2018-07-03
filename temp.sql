SET NOCOUNT ON
declare @shifts varchar(8000)
set @shifts = ''
SELECT @shifts = @shifts + 'CASE TA.'+ ATCR_COLUMN + ' WHEN ''Y'' THEN ''Y'' ELSE ''N'' END AS ATCR_' + REPLACE(RTRIM(ATCR_DESC), ' ', '_') + ' ,'  FROM TB_AGENCY_ATCR_DESC WHERE ATCR_DESC <> 'NOT DEFINED'
select @shifts = RTRIM(LEFT(@shifts,LEN(@shifts) - 1))

declare @s varchar(8000)
set @s = 'ALTER  VIEW VW_EMSA_DYNAMIC_AGENCIES AS
SELECT  LOWER(T2.EMailAddress) as EmailAddress,
        TR.RepCode AS [RepCode],
        TR.RegCode AS [RegionCode], 
        T1.AgencyName, 
        RR.FirstName as RegionRep_FirstName, 
        RR.LastName as RegionRep_LastName,
        TR.TerritoryCode,'
        + char(13) + char(10) + '       ' + @shifts + ',' + char(13) + char(10) +
'       TR.CYIndvPax as CurrentYearIndividualPax,
        TR.CYGrpPax as CurrentYearGroupPax,
        TR.PYIndvPax as PastYearIndividualPax, 
        TR.PYGrpPax as PastYearGroupPax, 
        ''Y'' as AgentEmail,  
        ''N'' as OwnerEmail,  
        CASE T2.CatPro WHEN ''Y'' THEN ''Y'' ELSE ''N'' END as ElegibleForPromotions,
        T2.AgencyId as CustomerNumber,
        T1.ZipCode, 
        T1.State,
        T1.CountryCode As CountryCode,
        T1.AgencyId as UserID,
        T1.City,
        T3.CountryName as Country,
        CASE WHEN (SELECT COUNT(*) FROM AgencyPromos T3 (NOLOCK) WHERE T1.AgencyID = T3.AgencyID AND T3.PromoType = ''P'' AND T3.PromoCode = ''M1'') > 0 THEN ''MILITARY'' ELSE ''NOT_MILITARY'' END AS Military,
        CASE WHEN (SELECT COUNT(*) FROM AgencyPromos T4 (NOLOCK) WHERE T1.AgencyID = T4.AgencyID AND T4.PromoType = ''P'' AND T4.PromoCode = ''GI'') > 0 THEN ''INTERLINE'' ELSE ''NOT_INTERLINE'' END AS Interline,
        COALESCE((SELECT RegionCode + Name  FROM TB_EMAIL_REGION T5 WHERE T1.State = T5.LookupVal AND T5.Type = ''State''),(SELECT RegionCode + Name  FROM TB_EMAIL_REGION T6 WHERE T1.CountryCode = T6.LookupVal AND T6.Type = ''Country'')) As Region

FROM tblAgencies T1 (NOLOCK)

JOIN tblAgencyEmail T2 (NOLOCK) on
    T1.AgencyId = T2.AgencyId
    AND T2.EmailAddress > ''''
    AND T2.EmailAddress 
    NOT IN 
    (
        SELECT EmailAddress FROM TB_OPTOUT T7 (NOLOCK) 
        WHERE T7.OptInFlag = 0
    )
    AND T2.EmailAddress 
    NOT IN 
    (
        SELECT EmailAddress FROM TB_BOUNCE_BACK T8 (NOLOCK)
        WHERE 
        T8.HardBounceCount > 5
    )
    AND T2.EmailID = 
    (
        select max(b.EmailID) from tblAgencyEmail b (NOLOCK)
        where T2.EmailAddress = b.EmailAddress
    )

JOIN tblTerms TR (NOLOCK) on
    T1.AgencyId = TR.AgencyID
    AND TR.MktInd NOT IN (''CLO'',''DEL'')
JOIN tblRegionRep RR (NOLOCK) on
    RR.RegionCode = TR.RegCode AND
    RR.RepCode = TR.RepCode

JOIN tblAgencyPhNumbers T6 (NOLOCK) on
    T6.AgencyId = T1.AgencyId
    AND T6.Type = 5

LEFT JOIN tblCountry T3 (NOLOCK) ON 
    T1.CountryCode = T3.CountryCode
LEFT JOIN tblStates T4 (NOLOCK) ON 
    T1.State = T4.cn
    
LEFT JOIN TB_AGENCY_ATCR TA (NOLOCK) on 
    TA.AgencyId = T1.AgencyId

WHERE 
    T1.ActiveInd = ''Y''

'
--select @s
EXEC(@s)