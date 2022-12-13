from pprint import pprint
import requests
from marshmallow import Schema, fields, RAISE, ValidationError


class DetailsSchema(Schema):
    message            = fields.String(required=True)
    shortMessage       = fields.String(required=True)
    resolution         = fields.String(allow_none=True, required=True)
    type               = fields.String(required=True)
    metaData           = fields.String(allow_none=True, required=True)


class InvalidDropPlayerSchema(Schema):

    class Meta:
        unknown = RAISE

    messages = fields.List(fields.String, required=True)
    details  =  fields.List(fields.Nested(DetailsSchema), required=True)

if __name__ == '__main__':
    target = 'https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/<leagueid>/transactions/'
    resp = requests.get(target)

    if resp.status_code == 200:
        try:
            page = InvalidDropPlayerSchema().load(resp.json())

        except ValidationError as ve:
            pprint(ve.messages)
        else:
            print(f'{target} received with status code {resp.status_code} has been Validated')
    else:
        print(f'Received unexpected status code {resp.status_code} from {target}')
