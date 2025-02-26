# -*- coding: utf-8; -*-
#
# This file is part of Superdesk.
#
# Copyright 2013, 2014 Sourcefabric z.u. and contributors.
#
# For the full copyright and license information, please see the
# AUTHORS and LICENSE files distributed with this source code, or
# at https://www.sourcefabric.org/superdesk/license

import logging
from typing import Optional
import xml.etree.ElementTree as ET

from datetime import datetime
from superdesk.errors import ParserError
from superdesk.io.feed_parsers import XMLFeedParser
from superdesk.io.registry import register_feed_parser
from superdesk.metadata.item import ITEM_TYPE, CONTENT_TYPE, GUID_FIELD, GUID_NEWSML, FORMAT, FORMATS
from superdesk.metadata.utils import generate_guid
from superdesk.utc import utcnow

logger = logging.getLogger(__name__)


class NTBEventXMLFeedParser(XMLFeedParser):
    """NTB Event XML parser.

    Feed Parser which can parse an NTB created XML file exported from Outlook
    the firstcreated and versioncreated times are localised.
    """

    NAME = 'ntb_event_xml'

    label = 'NTB Event XML'

    def can_parse(self, xml):
        return xml.tag.endswith('document')

    def parse_email(self, content, content_type, provider):
        if content_type != 'text/xml':
            raise ParserError.parseMessageError('Not supported content type.')

        content.seek(0)
        xml = ET.parse(content)
        return self.parse(xml.getroot(), provider)

    def parse_file(self, fstream, provider):
        xml = ET.parse(fstream)
        return self.parse(xml.getroot(), provider)

    def parse_http(self, content, provider):
        xml = ET.fromstring(content)
        return self.parse(xml, provider)

    def parse_datetime(self, value: str) -> Optional[datetime]:
        if value:
            return datetime.fromisoformat(value)
        return None

    def parse(self, xml, provider=None, content=None):
        items = []
        try:
            # parse xml file, only expecting one event per file
            if not ET.iselement(xml.find('guid')):
                guid = generate_guid(type=GUID_NEWSML)
            else:
                guid = xml.find('guid').text

            item = {
                ITEM_TYPE: CONTENT_TYPE.EVENT,
                GUID_FIELD: guid,
                FORMAT: FORMATS.PRESERVED
            }
            item['name'] = xml.find('title').text
            item['definition_short'] = xml.find('title').text
            item['definition_long'] = xml.find('content').text
            item['dates'] = {
                'start': self.parse_datetime(xml.find('timeStart').text),
                'end': self.parse_datetime(xml.find('timeEnd').text),
                'tz': ''
            }
            # add location
            item['location'] = [{
                'name': xml.find('location').text,
                'qcode': '',
                'geo': ''
            }]
            if ET.iselement(xml.find('geo')):
                geo = xml.find('geo')
                item['location'][0]['geo'] = '%s, %s' % (geo.find('latitude').text, geo.find('longitude').text)
            # IMPORTANT: firstcreated must be less than 2 days past
            # we must preserve the original event created and updated in some other fields
            item['firstcreated'] = utcnow()
            item['versioncreated'] = utcnow()
            items.append(item)

            return items
        except Exception as ex:
            raise ParserError.parseMessageError(ex, provider)


register_feed_parser(NTBEventXMLFeedParser.NAME, NTBEventXMLFeedParser())
