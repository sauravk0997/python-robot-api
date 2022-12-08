from pprint import pprint
import requests
from marshmallow import Schema, fields, RAISE, ValidationError


class DetailsSchema(Schema):
    message            = fields.String(required=True)
    shortMessage       = fields.String(required=True)
    resolution         = fields.String(allow_none=True, required=True)
    type               = fields.String(required=True)
    metaData           = fields.String(allow_none=True, required=True)


class InvalidSchema(Schema):

    class Meta:
        unknown = RAISE

    messages = fields.List(fields.String, required=True)
    details  =  fields.List(fields.Nested(DetailsSchema), required=False)