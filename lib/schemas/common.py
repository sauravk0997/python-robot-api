from marshmallow import Schema, fields, RAISE, ValidationError

class metaDataCustom(fields.Field):
    def _deserialize(self, entry, attr, ctx, **k):
        if isinstance(entry, str):
             pass
        elif isinstance(entry, list):
            pass
        elif isinstance(entry, dict):
            pass
        elif isinstance(entry, None):
            pass
        else:
            raise ValidationError(f'CustomField : Unexpected field type found. {type(entry)}')
