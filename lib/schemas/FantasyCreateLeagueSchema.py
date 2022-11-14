from marshmallow import Schema, fields, RAISE, ValidationError
from lib.schemas.FantasySportCommon import FantasyCreateLeagueOwners, FantasyCreateLeaguewatchList, FantasyCreateLeaguePreviousSeasons, FantasypreviousSeasons
from pprint import pprint

#TradeSettings Schema
class TradeSettingsSchema(Schema):
    class Meta:
        unknown = RAISE

    allowOutOfUniverse      = fields.Boolean(required=False)
    deadlineDate            = fields.Integer(required=True)
    max                     = fields.Integer(required=True)
    revisionHours           = fields.Integer(required=False)
    vetoVotesRequired       = fields.Integer(required=True)

#ScoringSettings Schema
class ScoringItemsSchema(Schema):
    class Meta:
        unknown = RAISE

    isReverseItem            = fields.Boolean(required=False)
    leagueRanking            = fields.Integer(required=True)
    leagueTotal              = fields.Integer(required=True)
    points                   = fields.Integer(required=False)
    #pointsOverrides          = fields.Nested(required=False)
    statId                   = fields.Integer(required=True)

#ScoringSettings Schema
class ScoringSettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    allowOutOfPositionScoring   = fields.Boolean(required=False)
    homeTeamBonus               = fields.Integer(required=True)
    matchupTieRule              = fields.String(required=True)
    playerRankType              = fields.String(required=False)
    playoffHomeTeamBonus        = fields.Integer(required=True)
    playoffMatchupTieRule        = fields.String(required=True)
    scoringType                 = fields.String(required=True)
    scoringItems                = fields.Raw(required=False)

#Division Schema
# class DivisionsSchema(Schema):
#     class Meta:
#         unknown = RAISE
    
#     id            = fields.Integer(required=False)
#     name          = fields.String(required=True)
#     size          = fields.Integer(required=True)

# Division Schema
class MatchupPeriodsSchema(Schema):
    class Meta:
        unknown = RAISE

#RosterSettings Schema
class ScheduleSettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    #divisions                     = fields.List(DivisionsSchema, required=False)
    divisions                    = fields.Raw(required=False)
    matchupPeriodCount           = fields.Integer(required=True)
    matchupPeriodLength          = fields.Integer(required=True)
    #matchupPeriods               = fields.FantasyCreateLeagueOwners()
    # matchupPeriods               = fields.Nested(MatchupPeriodsSchema, required=False);
    matchupPeriods               = fields.Raw(required=False)
    periodTypeId                 = fields.Integer(required=True)
    playoffMatchupPeriodLength   = fields.Integer(required=True)
    playoffSeedingRule           = fields.String(required=False)
    playoffTeamCount             = fields.Integer(required=True)

# #RosterSettings Schema
# class LineupSlotCountsSettingsSchema(Schema):
#     class Meta:
#         unknown = RAISE
    

#RosterSettings Schema
class RosterSettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    isBenchUnlimited            = fields.Boolean(required=True)
    isUsingUndroppableList      = fields.Boolean(required=True)
    lineupLocktimeType          = fields.String(required=True)
    moveLimit                   = fields.Integer(required=True)
    rosterLocktimeType          = fields.String(required=True)
    # lineupSlotCounts            = fields.Nested(LineupSlotCountsSettingsSchema, required=False)
    lineupSlotCounts            = fields.Raw(required=False)
    lineupSlotStatLimits        = fields.Raw(required=False)
    playerMoveToIR              = fields.Integer(required=False)
    universeIds                 = fields.Raw(required=False)
    positionLimits              = fields.Raw(required=False)

#FinanceSettings Schema
class FinanceSettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    entryFee            = fields.Integer(required=True)
    miscFee             = fields.Integer(required=True)
    perLoss             = fields.Integer(required=True)
    perTrade            = fields.Integer(required=True)
    playerAcquisition   = fields.Integer(required=True)
    playerDrop          = fields.Integer(required=False)
    playerMoveToActive  = fields.Integer(required=True)
    playerMoveToIR      = fields.Integer(required=True)

#DraftSettings Schema
class DraftSettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    auctionBudget       = fields.Integer(required=True)
    isTradingEnabled    = fields.Boolean(required=True)
    keeperCount         = fields.Integer(required=True)
    keeperOrderType     = fields.String(required=True)
    leagueSubType       = fields.String(required=True)
    orderType           = fields.String(required=False)
    pickOrder           = fields.Raw(required=False)
    timePerSelection    = fields.Integer(required=True)
    type                = fields.String(required=False)

#AcquistionSettings Schema
class AcquistionSettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    acquisitionBudget               = fields.Integer(required=True)
    acquisitionLimit                = fields.Integer(required=True)
    acquisitionType                 = fields.String(required=True)
    isUsingAcquisitionBudget        = fields.Boolean(required=True)
    isUsingVickreyRules             = fields.Boolean(required=True)
    matchupAcquisitionLimit         = fields.Integer(required=False)
    matchupLimitPerScoringPeriod    = fields.Boolean(required=True)
    minimumBid                      = fields.Integer(required=True)
    waiverHours                     = fields.Integer(required=False)
    waiverOrderReset                = fields.Boolean(required=True)
    waiverProcessHour               = fields.Integer(required=False)
    waiverProcessDays               = fields.Raw(required=False)

#Settings Schema
class SettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    isCustomizable              = fields.Boolean(required=True)
    isPublic                    = fields.Boolean(required=True)
    name                        = fields.String(required=True)
    restrictionType             = fields.String(required=True)
    size                        = fields.Integer(required=True)
    acquisitionSettings         = fields.Nested(AcquistionSettingsSchema, required=False)
    draftSettings               = fields.Nested(DraftSettingsSchema, required=False)
    financeSettings             = fields.Nested(FinanceSettingsSchema, required=False)
    rosterSettings              = fields.Nested(RosterSettingsSchema, required=False)
    scheduleSettings            = fields.Nested(ScheduleSettingsSchema, required=False)
    scoringSettings             = fields.Nested(ScoringSettingsSchema, required=False)
    tradeSettings               = fields.Nested(TradeSettingsSchema, required=False)

#Settings Schema
class PreviousSeasonSchema(Schema):   
    class Meta:
        pass
        # unknown = RAISE

#Status Schema
class StatusSchema(Schema):
    class Meta:
        unknown = RAISE
    
    activatedDate               = fields.Integer(required=True)
    createdAsLeagueType         = fields.Integer(required=True)
    currentLeagueType           = fields.Integer(required=True)
    currentMatchupPeriod        = fields.Integer(required=True)
    finalScoringPeriod          = fields.Integer(required=True)
    firstScoringPeriod          = fields.Integer(required=True)
    isActive                    = fields.Boolean(required=True)
    isExpired                   = fields.Boolean(required=True)
    isFull                      = fields.Boolean(required=True)
    isPlayoffMatchupEdited      = fields.Boolean(required=True)
    isToBeDeleted               = fields.Boolean(required=True)
    isViewable                  = fields.Boolean(required=True)
    isWaiverOrderEdited         = fields.Boolean(required=True)
    latestScoringPeriod         = fields.Integer(required=True)
   # previousSeasons             = FantasyCreateLeaguePreviousSeasons
    #previousSeasons             = fields.List(PreviousSeasonSchema, required=False)
    #previousSeasons             = fields.List(PreviousSeasonSchema, required=False)
    #previousSeasons             = FantasypreviousSeasons
    #previousSeasons             = fields.List(dump_only=True)
    previousSeasons             = fields.Raw(required=False)
    teamsJoined                 = fields.Integer(required=True)
    transactionScoringPeriod    = fields.Integer(required=True)
    waiverLastExecutionDate     = fields.Integer(required=True)
    waiverProcessStatus         = fields.Raw(required=False)
    
# #Groups Schema
# class OwnersSchema(Schema):
#     class Meta:
#         unknown = RAISE

#Teams Schema
class TeamsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    abbrev                  = fields.String(required=False)
    currentProjectedRank    = fields.Integer(required=False)
    divisionId              = fields.Integer(required=False)
    draftDayProjectedRank   = fields.Integer(required=False)
    id                      = fields.Integer(required=False)
    isActive                = fields.Boolean(required=False)
    location                = fields.String(required=False)
    logo                    = fields.String(required=False)
    nickname                = fields.String(required=False)
    # owners                  = fields.List(fields.Nested(OwnersSchema), required=False)
    owners                  = fields.Raw(required=False)
    playoffSeed             = fields.Integer(required=False)
    points                  = fields.Integer(required=False)
    primaryOwner            = fields.String(required=False)
    rankCalculatedFinal     = fields.Integer(required=False)
    rankFinal               = fields.Integer(required=False)
    waiverRank              = fields.Integer(required=False)
    #watchList               = fields.FantasyCreateLeaguewatchList()
    watchList               = fields.Raw(required=False)

#Metadata Schema
class NotificationSettingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    enabled   = fields.Boolean(required=False)
    forId     = fields.Integer(required=False)
    id        = fields.String(required=False)
    type      = fields.String(required=False)


#Members Schema
class MembersSchema(Schema):
    class Meta:
        unknown = RAISE

    displayName             = fields.String(required=True)
    firstName               = fields.String(required=True)
    fullName                = fields.String(required=True)
    hasLimitedPrivileges    = fields.Boolean(required=True)
    id                      = fields.String(required=False)
    inviteId                = fields.String(required=False)
    displayName             = fields.String(required=True)
    isLeagueCreator         = fields.Boolean(required=True)
    isLeagueManager         = fields.Boolean(required=True)
    lastName                = fields.String(required=True)
    notificationSettings    = fields.List(fields.Nested(NotificationSettingsSchema), required=False)

#Invite Schema
class InvitedSchema(Schema):
    class Meta:
        unknown = RAISE
    
    id                          = fields.String(required=True)
    inviteType                  = fields.String(required=True)
    isDeleted                   = fields.Boolean(required=False)
    teamId                      = fields.Integer(required=False)

#Create League Schema
class FantasyCreateLeagueSchema(Schema):
    """
        Schema for Fantasy Create API endpoints
    """
    class Meta:
        unknown = RAISE

    gameId                  = fields.Integer(required=True)
    id                      = fields.Integer(required=True)
    scoringPeriodId         = fields.Integer(required=True)
    seasonId                = fields.Integer(required=True)
    segmentId               = fields.Integer(required=True)
    invited                 = fields.List(fields.Nested(InvitedSchema), required=False)
    members                 = fields.List(fields.Nested(MembersSchema), required=False)
    teams                   = fields.List(fields.Nested(TeamsSchema), required=False)
    settings                = fields.Nested(SettingsSchema, required=False)
    status                  = fields.Nested(StatusSchema, required=False)