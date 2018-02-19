import re
import json
import uuid
import hashlib

from st2common.runners.base_action import Action


class CouchbaseSpec(Action):  # pylint: disable=too-few-public-methods
    def run(self, payload, config):

        self.defaults = {
            "instance_type": "t2.medium"
        }

        newpayload = {}

        # take the payload name and replace any non-alphanumerical characters with "-"
        # to create a name for the database
        try:
            #nsshort = re.sub('["-._]+', '', payload['namespace'])
            db_name = "%s%s%s%s" % (config['environment'], config['internal_domain'], payload['namespace'], re.sub('["-.]+', '', payload['name']))
            m = hashlib.sha1()
            m.update(db_name)
            tmp = list(m.hexdigest()[20:])
            if not tmp[0].isalpha():
                tmp[0] = 'a'
            obfname = ''.join(tmp)

        except:
            self.logger.exception('Cannot create valid name for database!')
            raise

        newpayload['namespace'] = payload['namespace']
        newpayload['dbname'] = obfname
        newpayload['name'] = payload['name']
        newpayload['engine'] = payload['object_kind'].lower()
        newpayload['pass'] = self._id_generator()

        for dflt in self.defaults:
            newpayload[dflt] = self.defaults[dflt]

        if 'options' in payload['spec'] and payload['spec']['options'] is not None: 

            # copy options to newpayload
            for spec in payload['spec']['options']:
                lspec = spec.lower()
                if lspec in vartypes:
                    if vartypes[lspec] == "int":
                        newpayload[spec] = int(payload['spec']['options'][spec])
                    elif vartypes[lspec] == "bool":
                        newpayload[spec] = boolconv[payload['spec']['options'][spec].lower()]
                else:
                    newpayload[spec] = payload['spec']['options'][spec].lower()

        # no options, no versions or replica counts
        else:
            newpayload['version'] = self.defaultversions[newpayload['engine']]

        return newpayload

    def _id_generator(self):
        return uuid.uuid4().hex