from marshmallow import Schema, fields, RAISE, ValidationError
import requests
from pprint import pprint


class DraftAutoJoinSettingsSchema(Schema):
    availableDaysInAdvance = fields.Integer(required=True)
    displayRecommendedTimesByDefault = fields.Boolean(required=True)
    allowableLeagueSizes = fields.List(fields.Integer(required=True))
    availableLocalTimes = fields.List(fields.List(fields.Integer(required=True)))
    recommendedLocalTimes = fields.List(fields.List(fields.Integer(required=True)))


class ClientFlagsSchema(Schema):
    ESPN_PLUS_ENABLED = fields.Boolean(required=True)
    IBM_TRADE_ASSISTANT = fields.Boolean(required=True)
    IBM_TRADE_ASSISTANT_FORK = fields.Boolean(required=True)
    WATSON_PLAYERCARD_ENABLED = fields.Boolean(required=True)
    IBM_TRADE_ANALYZER = fields.String(required=True)


class DraftScheduleSettingsSchema(Schema):
    draftAutoJoinSettings = fields.Nested(DraftAutoJoinSettingsSchema, required=True)
    endDate = fields.Integer(required=True)
    startDate = fields.Integer(required=True)
    liveLobbyGated = fields.Boolean(required=True)
    mockLobbyGated = fields.Boolean(required=True)


class StatSettingsSchema(Schema):
    showSeasonProjections = fields.Boolean(required=True)


class CurrentScoringPeriodSchema(Schema):
    id = fields.Integer(required=True)


class SettingsSchema(Schema):
    allowLeagueCreation = fields.Boolean(required=True)
    gated = fields.Boolean(required=True)
    proScheduleAvailable = fields.Boolean(required=True)
    clientFlags = fields.Nested(ClientFlagsSchema, required=True)
    draftScheduleSettings = fields.Nested(DraftScheduleSettingsSchema, required=True)
    statSettings = fields.Nested(StatSettingsSchema, required=True)


class CurrentSeasonSchema(Schema):
    currentScoringPeriod = fields.Nested(CurrentScoringPeriodSchema, required=True)
    settings = fields.Nested(SettingsSchema, required=True)
    id = fields.Integer(required=True)


class GamesSchema(Schema):
    """
        Schema for ESPN Fantasy Games API
    """

    class Meta:
        unknown = RAISE

    currentSeason = fields.Nested(CurrentSeasonSchema, required=False)
    currentSeasonId = fields.Integer(required=False)


if __name__ == '__main__':
    target = 'https://fantasy.espn.com/apis/v3/games/FFL/?platform=cinco_18914&view=cinco_wl_gameState&rand=27741223'
    resp = requests.get(target)

    if resp.status_code == 200:
        try:
            page = GamesSchema().load(resp.json())

        except ValidationError as ve:
            pprint(ve.messages)
        else:
            print(f'{target} received with status code {resp.status_code} has been Validated')
    else:
        print(f'Received unexpected status code {resp.status_code} from {target}')
