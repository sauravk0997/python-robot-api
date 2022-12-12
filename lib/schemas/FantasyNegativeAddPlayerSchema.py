from pprint import pprint
import requests
from marshmallow import Schema, fields, RAISE, ValidationError

class DetailsSchema(Schema):
    message            = fields.String(required=True)
    shortMessage       = fields.String(required=True)
    resolution         = fields.String(allow_none=True, required=True)
    type               = fields.String(required=True)
    metaData           = fields.Raw(required=False, allow_none=True)

class InvalidAddPlayerSchema(Schema):

    class Meta:
        unknown = RAISE

    messages = fields.List(fields.String, required=True)
    details  =  fields.List(fields.Nested(DetailsSchema), required=True)

if __name__ == '__main__':
    target = 'https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/'
    resp = requests.get(target)
    if resp.status_code == 200:
        try:
            page = InvalidAddPlayerSchema().load(resp.json())
        except ValidationError as ve:
            pprint(ve.messages)
        else:
            print(f'{target} received with status code {resp.status_code} has been Validated')
    else:
        print(f'Received unexpected status code {resp.status_code} from {target}')
