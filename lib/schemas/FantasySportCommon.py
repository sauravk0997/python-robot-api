from marshmallow import fields


class FantasySportFansChallengeGroups(fields.Field):
    def _deserialize(self, entry, attr, ctx, **k):
        pass

class FantasySportFansScoreByGroup(fields.Field):
    def _deserialize(self, entry, attr, ctx, **k):
        pass