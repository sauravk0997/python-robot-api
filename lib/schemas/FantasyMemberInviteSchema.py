
from marshmallow import Schema, fields, RAISE, ValidationError

#Invited Schema
class InvitedSchema(Schema):
    class Meta:
        unknown = RAISE

    contact         = fields.String(required=False)
    id              = fields.String(required=False)
    inviteType      = fields.String(required=False)
    inviter         = fields.String(required=False)
    isDeleted       = fields.Boolean(required=False)
    teamId          = fields.Integer(required=False)

#Member Invite Schema
class FantasyMemberInviteSchema(Schema):
    """
        Schema for Fantasy Member Invite
    """
    class Meta:
        unknown = RAISE
    
    x   = fields.List(fields.Nested(InvitedSchema), required=False)
