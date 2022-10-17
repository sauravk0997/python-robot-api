from marshmallow import Schema, fields, RAISE, ValidationError
from lib.schemas.FantasySportCommon import FantasySportFansChallengeGroups, FantasySportFansScoreByGroup
import requests
from pprint import pprint

#Type Schema
class TypeSchema(Schema):
    class Meta:
        unknown = RAISE
    
    id                    = fields.Integer(required=True)
    code                  = fields.String(required=True)
    isDelegated           = fields.Boolean(required=True)
    isDeletable           = fields.Boolean(required=True)
    maxAllowed            = fields.Integer(required=True)
    name                  = fields.String(required=True)
    
#Groups Schema
class GroupsSchema(Schema):
    class Meta:
        unknown = RAISE

    createDate      = fields.Integer(required=False)
    draftDate       = fields.Integer(required=False, allow_none=True)
    draftStatus     = fields.Integer(required=False)
    draftType       = fields.Integer(required=False)
    fantasyCastHref = fields.String(required=False, allow_none=True)
    groupId         = fields.Integer(required=True)
    groupManager    = fields.Boolean(required=True)
    groupName       = fields.String(required=True)
    groupSize       = fields.Integer(required=False)
    href            = fields.String(required=False, allow_none=True)
    lastUpdate      = fields.Integer(required=False)
    leagueStatus    = fields.Integer(required=False)
    losses          = fields.Integer(required=False)
    points          = fields.Integer(required=False)
    rank            = fields.Integer(required=False)
    ties            = fields.Integer(required=False)
    wins            = fields.Integer(required=False)
        
#Entry Metadata Schema
class EntryMetaDataSchema(Schema):
    class Meta:
        unknown = RAISE
    
    active              = fields.Boolean(required=True)
    customizable        = fields.Boolean(required=True)
    draftComplete       = fields.Boolean(required=True)
    draftInProgress     = fields.Boolean(required=True)
    leagueFormatTypeId  = fields.Integer(required=True)
    leagueSubTypeId     = fields.Integer(required=True)
    leagueTypeId        = fields.Integer(required=True)
    nextGen             = fields.Boolean(required=True)
    pointsDelta         = fields.Integer(required=True)
    scoringTypeId       = fields.Integer(required=True)
    streakLength         = fields.Integer(required=False)
    streakType       = fields.Integer(required=False)
    teamAbbrev          = fields.String(required=True)

#Group Setting Schema
class GroupSetttingsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    name    = fields.String(required=False)

#Challenge Group Schema
class ChallengeGroupsSchema(Schema):
    class Meta:
        unknown = RAISE

    GroupSetttings = fields.Nested(GroupSetttingsSchema, required=False)


#Logo URLs Schema
class LogoURLsSchema(Schema):
    class Meta:
        unknown = RAISE
    
    logoSecondary = fields.String(required=False)
    logoPrimary = fields.String(required=False)
    darkLogoURL = fields.String(required=False)
    lightLogoURL    = fields.String(required=False)

#Record Schema
class RecordSchema(Schema):
    class Meta:
        unknown = RAISE
    
    losses  = fields.Integer(required=False)
    wins    = fields.Integer(required=False)

#Score Schema
class ScoreSchema(Schema):
    class Meta:
        unknown = RAISE
    
    eliminated  = fields.Boolean(required=False)
    overallScore    = fields.Integer(required=False)
    percentile  = fields.Integer(required=False)
    rank    = fields.Integer(required=False)
    record  = fields.Nested(RecordSchema, required=False)

#Entry Schema
class EntrySchema(Schema):
    class Meta:
        unknown = RAISE
    
    createDate          = fields.Integer(required=False)
    entryId             = fields.Integer(required=False)
    entryLocation       = fields.String(required=False)
    entryNickname       = fields.String(required=False)
    gameId              = fields.Integer(required=False)
    lastUpdate          = fields.Integer(required=False)
    logoType            = fields.String(required=False)
    logoUrl             = fields.String(required=False)
    losses              = fields.Integer(required=False)
    points              = fields.Integer(required=False)
    rank                = fields.Integer(required=False)
    restrictionType     = fields.Integer(required=False)
    seasonId            = fields.Integer(required=False)
    ties                = fields.Integer(required=False)
    wins                = fields.Integer(required=False)
    entryURL            = fields.String(required=False)
    scoreboardFeedURL   = fields.String(required=False, allow_none=True)
    abbrev              = fields.String(required=False)
    name                = fields.String(required=False)
    description         = fields.String(required=False)
    logoURL             = fields.String(required=False)
    signupURL           = fields.String(required=False, allow_none=True)
    href                = fields.String(required=False)
    percentile          = fields.Integer(required=False)
    logoURLs            = fields.Nested(LogoURLsSchema, required=False)
    #challengeGroups     = fields.List(fields.Nested(ChallengeGroupsSchema), required=False, allow_none=True, partial=True)
    #challengeGroups     = fields.Str(partial=True) or fields.List(fields.Nested(ChallengeGroupsSchema), required=False, allow_none=True)
    #challengeGroups     = fields.List(fields.Nested(ChallengeGroupsSchema),partial=True)
    challengeGroups     = FantasySportFansChallengeGroups(required=False) 
    challengeId         = fields.Integer(required=False)
    lastAvailableDate   = fields.Integer(required=False)
    score               = fields.Nested( ScoreSchema, required=False)
    gameUrl             = fields.String(required=False)
    entryName           = fields.String(required=False)
    entryUuid           = fields.String(required=False)
    scoreByGroup        = FantasySportFansScoreByGroup(required=False)
    entryMetadata       = fields.Nested(EntryMetaDataSchema, required=False)
    groups              = fields.List(fields.Nested(GroupsSchema), required=False)

#Metadata Schema
class MetaDataSchema(Schema):
    class Meta:
        unknown = RAISE
    
    isLive   = fields.Boolean(required=False)
    inSeason = fields.Boolean(required=False)
    entry    = fields.Nested(EntrySchema, required=False)


#Profile Schema
class ProfileSchema(Schema):
    class Meta:
        unknown = RAISE
    
    id                          = fields.String(required=True)
    createDate                  = fields.Integer(required=True)
    hasNotificationPreferences  = fields.Boolean(required=True)
    isInsider                   = fields.Boolean(required=True)
    isPremium                   = fields.Boolean(required=True)
    lastUpdateDate              = fields.Integer(required=True)
    lastUpdateSource            = fields.String(required=True)
    useSortGlobal               = fields.Boolean(required=True)

#Preference Schema
class PreferenceSchema(Schema):
    class Meta:
        unknown = RAISE
    
    id                          = fields.String(required=True)
    createDate                  = fields.Integer(required=True)
    lastUpdateDate              = fields.Integer(required=False)
    createSource                = fields.String(required=False)
    lastUpdateSource            = fields.String(required=False)
    sortGlobal                  = fields.Integer(required=True)
    isHidden                    = fields.Boolean(required=True)
    typeId                      = fields.Integer(required=True)
    affinity                    = fields.Integer(required=True)
    isImplicit                  = fields.Boolean(required=False)
    metaData                    = fields.Nested(MetaDataSchema, required=False)
    type                        = fields.Nested(TypeSchema, required=False)


#Fans Schema
class FantasySportFansSchema(Schema):
    """
        Schema for Fantasy Fan API endpoints
    """
    class Meta:
        unknown = RAISE

    id                  = fields.String(required=True)
    anon                = fields.Boolean(required=True)
    createDate          = fields.String(required=True)
    createSource        = fields.String(required=True)
    lastAccessDate      = fields.String(required=True)
    lastAccessSource    = fields.String(required=False, allow_none=True)
    lastUpdateDate      = fields.String(required=True)
    lastUpdateSource    = fields.String(required=True)
    preferences         = fields.List(fields.Nested(PreferenceSchema), required=False)
    profile             = fields.Nested(ProfileSchema, required=False)


if __name__ == '__main__':
    target = 'https://fan.api.espn.com/apis/v2/fans/%7B6E458CFC-7B0E-4811-8B3D-504CF5F7D4C0%7D?displayHiddenPrefs=true&context=fantasy&useCookieAuth=true&source=fantasyapp-ios&featureFlags=challengeEntries'
    resp = requests.get(target)

    if resp.status_code == 200:
        try:
            page = FantasySportFansSchema().load(resp.json())

        except ValidationError as ve:
            pprint(ve.messages)
        else:
            print(f'{target} received with status code {resp.status_code} has been Validated')
    else:
        print(f'Received unexpected status code {resp.status_code} from {target}')
