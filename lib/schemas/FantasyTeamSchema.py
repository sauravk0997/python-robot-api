
from marshmallow import Schema, fields, RAISE, ValidationError


class TransactionsCounterSchema(Schema):
    class Meta:
        unknown = RAISE
    acquisitionBudgetSpent      = fields.Integer(required=True)
    acquisitions                = fields.Integer(required=True)
    drops                       = fields.Integer(required=True)
    matchupAcquisitionTotals    = fields.Raw(required=False)
    moveToActive                = fields.Integer(required=True)
    moveToIR                    = fields.Integer(required=True)
    paid                        = fields.Integer(required=True)
    teamCharges                 = fields.Integer(required=True)
    trades                      = fields.Integer(required=True)

class RosterSchema(Schema):
    class Meta:
        unknown = RAISE
    entries                = fields.Raw(required=False)

class overAllSchema(Schema):
    class Meta:
        unknown = RAISE
    gamesBack             = fields.Integer(required=True)
    losses                = fields.Integer(required=True)
    percentage            = fields.Integer(required=True)
    pointsAgainst         = fields.Integer(required=True)
    pointsFor             = fields.Integer(required=True)
    streakLength          = fields.Integer(required=True)
    streakType            = fields.String(required=True)
    ties                  = fields.Integer(required=True)
    wins                  = fields.Integer(required=True)

class HomeSchema(Schema):
    class Meta:
        unknown = RAISE
    gamesBack                = fields.Integer(required=True)
    losses                   = fields.Integer(required=True)
    percentage               = fields.Integer(required=True)
    pointsAgainst            = fields.Integer(required=True)
    pointsFor                = fields.Integer(required=True)
    streakLength             = fields.Integer(required=True)
    streakType               = fields.String(required=True)
    ties                     = fields.Integer(required=True)
    wins                     = fields.Integer(required=True)

class DivisionSchema(Schema):
    class Meta:
        unknown = RAISE
    gamesBack             = fields.Integer(required=True)
    losses                = fields.Integer(required=True)
    percentage            = fields.Integer(required=True)
    pointsAgainst         = fields.Integer(required=True)
    pointsFor             = fields.Integer(required=True)
    streakLength          = fields.Integer(required=True)
    streakType            = fields.String(required=True)
    ties                  = fields.Integer(required=True)
    wins                  = fields.Integer(required=True)

class AwaySchema(Schema):
    class Meta:
        unknown = RAISE
    gamesBack                = fields.Integer(required=True)
    losses                   = fields.Integer(required=True)
    percentage               = fields.Integer(required=True)
    pointsAgainst            = fields.Integer(required=True)
    pointsFor                = fields.Integer(required=True)
    streakLength             = fields.Integer(required=True)
    streakType               = fields.String(required=True)
    ties                     = fields.Integer(required=True)
    wins                     = fields.Integer(required=True)
    
class RecordSchema(Schema):
    class Meta:
        unknown = RAISE
    
    away                = fields.Nested(AwaySchema, required=True)
    division            = fields.Nested(DivisionSchema,required=True)
    headToHead          = fields.Raw(required=True)
    home                = fields.Nested(HomeSchema,required=True)
    overall             = fields.Nested(overAllSchema,required=True)

#Fantasy Teams Schema
class FantasyTeamSchema(Schema):
    """
        Schema for Fantasy Fan API endpoints
    """
    class Meta:
        unknown = RAISE

    abbrev                  = fields.String(required=True)
    divisionId              = fields.Integer(required=True)
    draftStrategy           = fields.Raw(required=True)
    id                      = fields.Integer(required=True)
    isActive                = fields.Boolean(required=True)
    location                = fields.String(required=False)
    logo                    = fields.String(required=True)
    logoType                = fields.String(required=True)
    nickname                = fields.String(required=False) 
    owners                  = fields.Raw(required=False)
    playoffSeed             = fields.Integer(required=False)
    points                  = fields.Integer(required=True)
    pointsAdjusted          = fields.Integer(required=True)
    pointsDelta             = fields.Integer(required=False)
    primaryOwner            = fields.String(required=False)
    rankCalculatedFinal     = fields.Integer(required=False)
    rankFinal               = fields.Integer(required=False)
    recommendationHistory   = fields.Raw(required=False)
    waiverRank              = fields.Raw(required=False)
    watchList               = fields.Raw(required=False)
    tradeBlock              = fields.Raw(required=False)
    record                  = fields.Nested(RecordSchema, required=False)
    roster                  = fields.Nested(RosterSchema, required=False)
    transactionCounter      = fields.Nested(TransactionsCounterSchema, required=False)