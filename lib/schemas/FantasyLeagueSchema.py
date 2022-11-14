from marshmallow import Schema, fields, RAISE


class ItemsSchema(Schema):
    class Meta:
        unknown = RAISE

    fromLineupSlotId = fields.Int(required=True)
    fromTeamId = fields.Int(required=True)
    isKeeper = fields.Bool(required=True)
    overallPickNumber = fields.Int(required=True)
    playerId = fields.Int(required=True)
    toLineupSlotId = fields.Int(required=True)
    toTeamId = fields.Int(required=True)
    type = fields.String(required=True)


class MovePlayerSchema(Schema):
    class Meta:
        unknown = RAISE

    bidAmount = fields.Int(required=True)
    executionType = fields.String(required=True)
    id = fields.String(required=True)
    isActingAsTeamOwner = fields.Bool(required=True)
    isLeagueManager = fields.Bool(required=True)
    isPending = fields.Bool(required=True)
    items = fields.List(fields.Nested(ItemsSchema), required=True)
    memberId = fields.String(required=True)
    proposedDate = fields.Int(required=True)
    rating = fields.Int(required=True)
    scoringPeriodId = fields.Int(required=True)
    skipTransactionCounters = fields.Bool(required=True)
    status = fields.String(required=True)
    subOrder = fields.Int(required=True)
    teamId = fields.Int(required=True)
    type = fields.String(required=True)
