/*-------------------------------------
 * Timeline JS Functions
 * Version: 1.1 (22.04.2016)
 * Author:  Daniel Hochleitner
 *-------------------------------------
*/
FUNCTION render_timeline(p_region              IN apex_plugin.t_region,
                         p_plugin              IN apex_plugin.t_plugin,
                         p_is_printer_friendly IN BOOLEAN)
  RETURN apex_plugin.t_region_render_result IS
  -- plugin attributes
  l_headline           VARCHAR2(500) := p_region.attribute_01;
  l_description        VARCHAR2(2000) := p_region.attribute_02;
  l_preview_url        VARCHAR2(200) := p_region.attribute_03;
  l_caption            VARCHAR2(500) := p_region.attribute_04;
  l_font               VARCHAR2(50) := p_region.attribute_05;
  l_language           VARCHAR2(50) := p_region.attribute_06;
  l_width              VARCHAR2(50) := p_region.attribute_07;
  l_height             VARCHAR2(50) := p_region.attribute_08;
  l_start_date_column  VARCHAR2(100) := p_region.attribute_09;
  l_end_date_column    VARCHAR2(100) := p_region.attribute_10;
  l_headline_column    VARCHAR2(100) := p_region.attribute_11;
  l_description_column VARCHAR2(100) := p_region.attribute_12;
  l_media_url_column   VARCHAR2(100) := p_region.attribute_13;
  l_timeline_type      VARCHAR2(100) := p_region.attribute_14;
  -- other variables
  l_region_id              VARCHAR2(100);
  l_timeline_config_string VARCHAR2(2000);
  l_timeline_json_string   CLOB;
  l_column_value_list      apex_plugin_util.t_column_value_list2;
  --
  l_start_date_no  PLS_INTEGER;
  l_end_date_no    PLS_INTEGER;
  l_headline_no    PLS_INTEGER;
  l_description_no PLS_INTEGER;
  l_media_url_no   PLS_INTEGER;
  --
  l_start_date_value  DATE;
  l_end_date_value    DATE;
  l_headline_value    VARCHAR2(500);
  l_description_value VARCHAR2(4000);
  l_media_url_value   VARCHAR2(500);
  --
BEGIN
  -- set variables
  l_region_id := apex_escape.html_attribute(p_region.static_id ||
                                            '_timeline');
  --
  -- add div for timeline
  sys.htp.p('<div id="' || l_region_id || '"></div>');
  --
  -- add timeline js (storyjs-embed.js)
  apex_javascript.add_library(p_name           => 'storyjs-embed',
                              p_directory      => p_plugin.file_prefix ||
                                                  'js/',
                              p_version        => NULL,
                              p_skip_extension => FALSE);
  -- type: timeline slider only css
  IF l_timeline_type = 'SLIDERONLY' THEN
    apex_css.add(p_css => 'div#' || l_region_id ||
                          ' .vco-feature { display: none; } div#' ||
                          l_region_id || ' .vco-slider { display: none; }');
  END IF;
  --
  -- Get Data from Source
  l_column_value_list := apex_plugin_util.get_data2(p_sql_statement  => p_region.source,
                                                    p_min_columns    => 3,
                                                    p_max_columns    => 5,
                                                    p_component_name => p_region.name);
  --
  -- Get columns and validate
  l_start_date_no  := apex_plugin_util.get_column_no(p_attribute_label   => 'Start Date',
                                                     p_column_alias      => l_start_date_column,
                                                     p_column_value_list => l_column_value_list,
                                                     p_is_required       => TRUE,
                                                     p_data_type         => apex_plugin_util.c_data_type_date);
  l_end_date_no    := apex_plugin_util.get_column_no(p_attribute_label   => 'End Date',
                                                     p_column_alias      => l_end_date_column,
                                                     p_column_value_list => l_column_value_list,
                                                     p_is_required       => TRUE,
                                                     p_data_type         => apex_plugin_util.c_data_type_date);
  l_headline_no    := apex_plugin_util.get_column_no(p_attribute_label   => 'Headline',
                                                     p_column_alias      => l_headline_column,
                                                     p_column_value_list => l_column_value_list,
                                                     p_is_required       => TRUE,
                                                     p_data_type         => apex_plugin_util.c_data_type_varchar2);
  l_description_no := apex_plugin_util.get_column_no(p_attribute_label   => 'Description',
                                                     p_column_alias      => l_description_column,
                                                     p_column_value_list => l_column_value_list,
                                                     p_is_required       => FALSE,
                                                     p_data_type         => apex_plugin_util.c_data_type_varchar2);
  l_media_url_no   := apex_plugin_util.get_column_no(p_attribute_label   => 'Media URL',
                                                     p_column_alias      => l_media_url_column,
                                                     p_column_value_list => l_column_value_list,
                                                     p_is_required       => FALSE,
                                                     p_data_type         => apex_plugin_util.c_data_type_varchar2);
  --
  -- json header timeline
  l_timeline_json_string := '{ "timeline": {"headline":"' ||
                            REPLACE(REPLACE(REPLACE(l_headline,
                                                    '"',
                                                    ' '),
                                            chr(10),
                                            ' '),
                                    chr(13),
                                    ' ') || '","type":"default","text":"' ||
                            REPLACE(REPLACE(REPLACE(l_description,
                                                    '"',
                                                    ' '),
                                            chr(10),
                                            ' '),
                                    chr(13),
                                    ' ') || '",';
  l_timeline_json_string := l_timeline_json_string || '"asset": {"media":"' ||
                            l_preview_url ||
                            '","credit":"","caption":""},"date": [';
  --
  -- get values from sql query (loop) and write json
  FOR l_row_num IN 1 .. l_column_value_list(1).value_list.count LOOP
    -- start date
    l_start_date_value := apex_plugin_util.get_value_as_varchar2(p_data_type => l_column_value_list(l_start_date_no)
                                                                                .data_type,
                                                                 p_value     => l_column_value_list(l_start_date_no)
                                                                                .value_list(l_row_num));
    IF l_row_num = 1 THEN
      l_timeline_json_string := l_timeline_json_string || '{"startDate":"' ||
                                to_char(l_start_date_value,
                                        'YYYY,MM,DD') || '",';
    ELSE
      l_timeline_json_string := l_timeline_json_string || ',{"startDate":"' ||
                                to_char(l_start_date_value,
                                        'YYYY,MM,DD') || '",';
    END IF;
    -- end date
    l_end_date_value       := apex_plugin_util.get_value_as_varchar2(p_data_type => l_column_value_list(l_end_date_no)
                                                                                    .data_type,
                                                                     p_value     => l_column_value_list(l_end_date_no)
                                                                                    .value_list(l_row_num));
    l_timeline_json_string := l_timeline_json_string || '"endDate":"' ||
                              to_char(l_end_date_value,
                                      'YYYY,MM,DD') || '",';
    -- headline
    l_headline_value       := apex_plugin_util.get_value_as_varchar2(p_data_type => l_column_value_list(l_headline_no)
                                                                                    .data_type,
                                                                     p_value     => l_column_value_list(l_headline_no)
                                                                                    .value_list(l_row_num));
    l_headline_value       := apex_plugin_util.replace_substitutions(p_value  => l_headline_value,
                                                                     p_escape => TRUE);
    l_timeline_json_string := l_timeline_json_string || '"headline":"' ||
                              REPLACE(REPLACE(REPLACE(l_headline_value,
                                                      '"',
                                                      ' '),
                                              chr(10),
                                              ' '),
                                      chr(13),
                                      ' ') || '",';
    -- description
    IF l_description_no IS NOT NULL THEN
      l_description_value := apex_plugin_util.get_value_as_varchar2(p_data_type => l_column_value_list(l_description_no)
                                                                                   .data_type,
                                                                    p_value     => l_column_value_list(l_description_no)
                                                                                   .value_list(l_row_num));
    END IF;
    IF l_description_value IS NULL THEN
      l_timeline_json_string := l_timeline_json_string || '"text":"",';
    ELSE
      l_description_value    := apex_plugin_util.replace_substitutions(p_value  => l_description_value,
                                                                       p_escape => TRUE);
      l_timeline_json_string := l_timeline_json_string || '"text":"' ||
                                REPLACE(REPLACE(REPLACE(l_description_value,
                                                        '"',
                                                        ' '),
                                                chr(10),
                                                ' '),
                                        chr(13),
                                        ' ') || '",';
    END IF;
    -- media url
    IF l_media_url_no IS NOT NULL THEN
      l_media_url_value := apex_plugin_util.get_value_as_varchar2(p_data_type => l_column_value_list(l_media_url_no)
                                                                                 .data_type,
                                                                  p_value     => l_column_value_list(l_media_url_no)
                                                                                 .value_list(l_row_num));
    END IF;
    IF l_media_url_value IS NULL THEN
      l_timeline_json_string := l_timeline_json_string ||
                                '"asset":{"media":"","credit":"","caption":""}';
    ELSE
      l_media_url_value      := apex_plugin_util.replace_substitutions(p_value  => l_media_url_value,
                                                                       p_escape => TRUE);
      l_timeline_json_string := l_timeline_json_string ||
                                '"asset":{"media":"' || l_media_url_value ||
                                '","credit":"","caption":""}';
    END IF;
    --
    l_timeline_json_string := l_timeline_json_string || '}';
  END LOOP;
  --
  -- json footer timeline
  l_timeline_json_string := l_timeline_json_string || ']}}';
  --
  -- write inline timeline json
  apex_javascript.add_inline_code(p_code => 'var dataObject_' ||
                                            l_region_id || ' = ' ||
                                            l_timeline_json_string);
  --
  --
  -- timeline config
  l_timeline_config_string := 'createStoryJS({type: ''timeline''';
  l_timeline_config_string := l_timeline_config_string || ', width: ''' ||
                              l_width || '''';
  l_timeline_config_string := l_timeline_config_string || ', height: ''' ||
                              l_height || '''';
  l_timeline_config_string := l_timeline_config_string ||
                              ', source: dataObject_' || l_region_id;
  l_timeline_config_string := l_timeline_config_string || ', embed_id: ''' ||
                              l_region_id || '''';
  l_timeline_config_string := l_timeline_config_string || ', font: ''' ||
                              l_font || '''';
  l_timeline_config_string := l_timeline_config_string || ', lang: ''' ||
                              l_language || '''';
  l_timeline_config_string := l_timeline_config_string || ' });';
  --
  -- write inline timeline config
  apex_javascript.add_inline_code(p_code => l_timeline_config_string);
  --
  RETURN NULL;
  --
END render_timeline;