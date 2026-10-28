"""Check formatting semantics against OOXML style/direct-format distinctions."""
import sys
import unittest
from pathlib import Path
from lxml import etree as E
sys.path.insert(0, str(Path(__file__).resolve().parents[1]/'scripts'))
from inspect_official import props, merge_style, merge_props, NS


class EffectiveStyleTests(unittest.TestCase):
    def test_style_bold_toggle_and_direct_regular(self):
        bold = {'b.val': {'value': True, 'source': 'base'}}
        twice = merge_style(bold, {'b.val': {'value': True, 'source': 'derived'}})
        self.assertFalse(twice['b.val']['value'])
        unchanged = merge_style(bold, {'b.val': {'value': False, 'source': 'derived'}})
        self.assertTrue(unchanged['b.val']['value'])
        regular = merge_props(bold, {'b.val': {'value': False, 'source': 'direct'}})
        self.assertFalse(regular['b.val']['value'])

    def test_specific_font_overrides_inherited_theme_and_reverse(self):
        theme = {'rFonts.asciiTheme': {'value':'minorHAnsi', 'source':'defaults'}}
        explicit = {'rFonts.ascii': {'value':'Times New Roman', 'source':'paragraph style'}}
        self.assertNotIn('rFonts.asciiTheme', merge_props(theme, explicit))
        self.assertNotIn('rFonts.ascii', merge_props(explicit, theme))

    def test_nested_numbering_and_direct_false(self):
        xml = E.fromstring(('<w:pPr xmlns:w="'+NS['w']+'"><w:numPr><w:numId w:val="7"/></w:numPr>'
                            '<w:rPr><w:b w:val="0"/></w:rPr></w:pPr>').encode())
        result = props(xml, 'P1')
        self.assertEqual(result['numPr.numId.val']['value'], '7')
        self.assertFalse(result['rPr.b.val']['value'])


if __name__ == '__main__':
    unittest.main()
