from marshmallow import Schema, fields, RAISE, ValidationError
import requests
from pprint import pprint


class ItemsSchema(Schema):

    class Meta:
        unknown = RAISE

    fromLineupSlotId    = fields.Integer(required=True)
    fromTeamId          = fields.Integer(required=True)
    isKeeper            = fields.Boolean(required=True)
    overallPickNumber   = fields.Integer(required=True)
    playerId            = fields.Integer(required=True)
    toLineupSlotId      = fields.Integer(required=True)
    toTeamId            = fields.Integer(required=True)
    type                = fields.String(required=True)


class DropSchema(Schema):
    """
        Schema for ESPN Fantasy Games API
    """

    class Meta:
        unknown = RAISE

    bidAmount                   = fields.Integer(required=True)
    executionType               = fields.String(required=True)
    id                          = fields.String(required=True)
    isActingAsTeamOwner         = fields.Boolean(required=True)
    isLeagueManager             = fields.Boolean(required=True)
    isPending                   = fields.Boolean(required=True)
    items                       = fields.List(fields.Nested(ItemsSchema), required=False)
    memberId                    = fields.String(required=True)
    proposedDate                = fields.Integer(required=True)
    rating                      = fields.Integer(required=True)
    scoringPeriodId             = fields.Integer(required=True)
    skipTransactionCounters     = fields.Boolean(required=True)
    status                      = fields.String(required=True)
    subOrder                    = fields.Integer(required=True)
    teamId                      = fields.Integer(required=True)
    type                        = fields.String(required=True)

if __name__ == '__main__':
    target = 'https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/'
    resp = requests.get(target)

    if resp.status_code == 200:
        try:
            page = DropSchema().load(resp.json())

        except ValidationError as ve:
            pprint(ve.messages)
        else:
            print(f'{target} received with status code {resp.status_code} has been Validated')
    else:
        print(f'Received unexpected status code {resp.status_code} from {target}')
