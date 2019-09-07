additional_data_fields <- function() {
  
  list(
    aa1 = list(
      long_names = c(
        "aa1_liq_precip_period_quantity",
        "aa1_liq_precip_depth_dimension",
        "aa1_liq_precip_condition_code",
        "aa1_liq_precip_quality_code"
      ),
      field_lengths = c(2, 4, 1, 1),
      scale_factors = c(1, 10, NA_real_, NA_real_),
      data_types    = "nncc"
    ),
    ab1 = list(
      long_names = c(
        "ab1_liq_precip_monthly_depth_dimension",
        "ab1_liq_precip_monthly_condition_code",
        "ab1_liq_precip_monthly_quality_code"
      ),
      field_lengths = c(5, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_),
      data_types    = "ncc"
    ),
    ac1 = list(
      long_names = c(
        "ac1_precip_obs_history_duration_code",
        "ac1_precip_obs_history_characteristic_code",
        "ac1_precip_obs_history_quality_code"
      ),
      field_lengths = c(1, 1, 1),
      scale_factors = c(NA_real_, NA_real_, NA_real_),
      data_types    = "ccc"
    ),
    ad1 = list(
      long_names = c(
        "ad1_liq_precip_greatest_amt_24h_month_depth_dimension",
        "ad1_liq_precip_greatest_amt_24h_month_condition_code",
        "ad1_liq_precip_greatest_amt_24h_month_dates",
        "ad1_liq_precip_greatest_amt_24h_month_quality_code"
        ),
      field_lengths = c(5, 1, 4, 4, 4, 1),
      scale_factors = c(10, NA, NA, NA, NA, NA),
      data_types    = "nccccc"
    ),
    ae1 = list(
      long_names = c(
        "ae1_liq_precip_number_days_amt_month__01inch",
        "ae1_liq_precip_number_days_amt_month__01inch_quality_code",
        "ae1_liq_precip_number_days_amt_month__10inch",
        "ae1_liq_precip_number_days_amt_month__10inch_quality_code",
        "ae1_liq_precip_number_days_amt_month__50inch",
        "ae1_liq_precip_number_days_amt_month__50inch_quality_code",
        "ae1_liq_precip_number_days_amt_month_1_00inch",
        "ae1_liq_precip_number_days_amt_month_1_00inch_quality_code"
      ),
      field_lengths = c(2, 1, 2, 1, 2, 1, 2, 1),
      scale_factors = rep(NA_real_, 8),
      data_types    = "cccccccc"
    ),
    ag1 = list(
      long_names = c(
        "ag1_precip_est_obs_discrepancy_code",
        "ag1_precip_est_obs_est_water_depth_dimension"
      ),
      field_lengths = c(1, 3),
      scale_factors = c(NA_real_, 1),
      data_types    = "cn"
    ),
    ah1 = list(
      long_names = c(
        "ah1_liq_precip_max_short_dur_month_period_quantity",
        "ah1_liq_precip_max_short_dur_month_depth_dimension",
        "ah1_liq_precip_max_short_dur_month_condition_code",
        "ah1_liq_precip_max_short_dur_month_end_date_time",
        "ah1_liq_precip_max_short_dur_month_quality_code"
      ),
      field_lengths = c(3, 4, 1, 6, 1),
      scale_factors = c(1, 10, NA_real_, NA_real_, NA_real_),
      data_types    = "nnccc"
    ),
    ai1 = list(
      long_names = c(
        "ai1_liq_precip_max_short_dur_month_period_quantity",
        "ai1_liq_precip_max_short_dur_month_depth_dimension",
        "ai1_liq_precip_max_short_dur_month_condition_code",
        "ai1_liq_precip_max_short_dur_month_end_date_time",
        "ai1_liq_precip_max_short_dur_month_quality_code"
      ),
      field_lengths = c(4, 1, 6, 1),
      scale_factors = c(10, NA_real_, NA_real_, NA_real_),
      data_types    = "nccc"
    ),
    aj1 = list(
      long_names = c(
        "aj1_snow_depth_dimension",
        "aj1_snow_depth_condition_code",
        "aj1_snow_depth_quality_code",
        "aj1_snow_depth_equiv_water_depth_dimension",
        "aj1_snow_depth_equiv_water_condition_code",
        "aj1_snow_depth_equiv_water_quality_code"
      ),
      field_lengths = c(4, 1, 1, 6, 1, 1),
      scale_factors = c(1, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nccncc"
    ),
    ak1 = list(
      long_names = c(
        "ak1_snow_depth_greatest_depth_month_depth_dimension",
        "ak1_snow_depth_greatest_depth_month_condition_code",
        "ak1_snow_depth_greatest_depth_month_dates_occurrence",
        "ak1_snow_depth_greatest_depth_month_quality_code"
      ),
      field_lengths = c(4, 1, 6, 1),
      scale_factors = c(1, NA_real_, NA_real_, NA_real_),
      data_types    = "nccc"
    ),
    al1 = list(
      long_names = c(
        "al1_snow_accumulation_period_quantity",
        "al1_snow_accumulation_depth_dimension",
        "al1_snow_accumulation_condition_code",
        "al1_snow_accumulation_quality_code"
      ),
      field_lengths = c(2, 3, 1, 1),
      scale_factors = c(1, 1, NA_real_, NA_real_),
      data_types    = "nncc"
    ),
    am1 = list(
      long_names = c(
        "am1_snow_accumulation_greatest_amt_24h_month_depth_dimension",
        "am1_snow_accumulation_greatest_amt_24h_month_condition_code",
        "am1_snow_accumulation_greatest_amt_24h_month_dates_occurrence_1",
        "am1_snow_accumulation_greatest_amt_24h_month_dates_occurrence_2",
        "am1_snow_accumulation_greatest_amt_24h_month_dates_occurrence_3",
        "am1_snow_accumulation_greatest_amt_24h_month_quality_code"
      ),
      field_lengths = c(4, 1, 4, 4, 4, 1),
      scale_factors = c(10, NA, NA, NA, NA, NA),
      data_types    = "nccccc"
    ),
    an1 = list(
      long_names = c(
        "an1_snow_accumulation_month_period_quantity",
        "an1_snow_accumulation_month_depth_dimension",
        "an1_snow_accumulation_month_condition_code",
        "an1_snow_accumulation_month_quality_code"
      ),
      field_lengths = c(3, 4, 1, 1),
      scale_factors = c(1, 10, NA_real_, NA_real_),
      data_types    = "nncc"
    ),
    ao1 = list(
      long_names = c(
        "ao1_liq_precip_period_quantity_minutes",
        "ao1_liq_precip_depth_dimension",
        "ao1_liq_precip_condition_code",
        "ao1_liq_precip_quality_code"
      ),
      field_lengths = c(2, 4, 1, 1),
      scale_factors = c(1, 10, NA_real_, NA_real_),
      data_types    = "nncc"
    ),
    ap1 = list(
      long_names = c(
        "ap1_15_min_liq_precip_hpd_gauge_value_45_min_prior",
        "ap1_15_min_liq_precip_hpd_gauge_value_30_min_prior",
        "ap1_15_min_liq_precip_hpd_gauge_value_15_min_prior",
        "ap1_15_min_liq_precip_hpd_gauge_value_at_obs_time"
      ),
      field_lengths = c(4, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_),
      data_types    = "ncc"
    ),
    au1 = list(
      long_names = c(
        "au1_present_weather_obs_intensity_code",
        "au1_present_weather_obs_descriptor_code",
        "au1_present_weather_obs_precipitation_code",
        "au1_present_weather_obs_obscuration_code",
        "au1_present_weather_obs_other_weather_phenomena_code",
        "au1_present_weather_obs_combination_indicator_code",
        "au1_present_weather_obs_quality_code"
      ),
      field_lengths = c(1, 1, 2, 1, 1, 1, 1),
      scale_factors = rep(NA_real_, 7),
      data_types    = "ccccccc"
    ),
    aw1 = list(
      long_names = c(
        "aw1_present_weather_obs_aut_weather_report_1",
        "aw1_present_weather_obs_aut_weather_report_2",
        "aw1_present_weather_obs_aut_weather_report_3",
        "aw1_present_weather_obs_aut_weather_report_4"
      ),
      # TODO: lengths don't match
      field_lengths = c(2, 1),
      scale_factors = c(NA_real_, NA_real_),
      data_types    = "cc"
    ),
    ax1 = list(
      long_names = c(
        "ax1_past_weather_obs_atmos_condition_code",
        "ax1_past_weather_obs_quality_manual_atmos_condition_code",
        "ax1_past_weather_obs_period_quantity",
        "ax1_past_weather_obs_period_quality_code"
      ),
      field_lengths = c(2, 1, 2, 1),
      scale_factors = c(NA_real_, NA_real_, 1, NA_real_),
      data_types    = "ccnc"
    ),
    ay1 = list(
      long_names = c(
        "ay1_past_weather_obs_manual_occurrence_identifier",
        "ay1_past_weather_obs_quality_manual_atmos_condition_code",
        "ay1_past_weather_obs_period_quantity",
        "ay1_past_weather_obs_period_quality_code"
      ),
      field_lengths = c(1, 1, 2, 1),
      scale_factors = c(NA_real_, NA_real_, 1, NA_real_),
      data_types    = "ccnc"
    ),
    az1 = list(
      long_names = c(
        "az1_past_weather_obs_aut_occurrence_identifier",
        "az1_past_weather_obs_quality_aut_atmos_condition_code",
        "az1_past_weather_obs_period_quantity",
        "az1_past_weather_obs_period_quality_code"
      ),
      field_lengths = c(1, 1, 2, 1),
      scale_factors = c(NA_real_, NA_real_, 1, NA_real_),
      data_types    = "ccnc"
    ),
    cb1 = list(
      long_names = c(
        "cb1_subhrly_obs_liq_precip_2_sensor_period_quantity",
        "cb1_subhrly_obs_liq_precip_2_sensor_precip_liq_depth",
        "cb1_subhrly_obs_liq_precip_2_sensor_qc_quality_code",
        "cb1_subhrly_obs_liq_precip_2_sensor_flag_quality_code"
      ),
      field_lengths = c(2, 6, 1, 1),
      scale_factors = c(1, 10, NA_real_, NA_real_),
      data_types    = "nncc"
    ),
    cf1 = list(
      long_names = c(
        "cf1_hrly_fan_speed_rate",
        "cf1_hrly_fan_qc_quality_code",
        "cf1_hrly_fan_flag_quality_code"
      ),
      field_lengths = c(4, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_),
      data_types    = "ncc"
    ),
    cg1 = list(
      long_names = c(
        "cg1_subhrly_obs_liq_precip_1_sensor_precip_liq_depth",
        "cg1_subhrly_obs_liq_precip_1_sensor_qc_quality_code",
        "cg1_subhrly_obs_liq_precip_1_sensor_flag_quality_code"
      ),
      field_lengths = c(6, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_),
      data_types    = "ncc"
    ),
    ch1 = list(
      long_names = c(
        "ch1_hrly_subhrly_rh_temp_period_quantity",
        "ch1_hrly_subhrly_temp_avg_air_temp",
        "ch1_hrly_subhrly_temp_qc_quality_code",
        "ch1_hrly_subhrly_temp_flag_quality_code",
        "ch1_hrly_subhrly_rh_avg_rh",
        "ch1_hrly_subhrly_rh_qc_quality_code",
        "ch1_hrly_subhrly_rh_flag_quality_code"
      ),
      field_lengths = c(2, 5, 1, 1, 4, 1, 1),
      scale_factors = c(1, 10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nnccncc"
    ),
    ci1 = list(
      long_names = c(
        "ci1_hrly_rh_temp_min_hrly_temp",
        "ci1_hrly_rh_temp_min_hrly_temp_qc_quality_code",
        "ci1_hrly_rh_temp_min_hrly_temp_flag_quality_code",
        "ci1_hrly_rh_temp_max_hrly_temp",
        "ci1_hrly_rh_temp_max_hrly_temp_qc_quality_code",
        "ci1_hrly_rh_temp_max_hrly_temp_flag_quality_code",
        "ci1_hrly_rh_temp_std_dev_hrly_temp",
        "ci1_hrly_rh_temp_std_dev_hrly_temp_qc_quality_code",
        "ci1_hrly_rh_temp_std_dev_hrly_temp_flag_quality_code",
        "ci1_hrly_rh_temp_std_dev_hrly_rh",
        "ci1_hrly_rh_temp_std_dev_hrly_rh_qc_quality_code",
        "ci1_hrly_rh_temp_std_dev_hrly_rh_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 5, 1, 1, 5, 1, 1, 5, 1, 1),
      scale_factors = rep(c(10, NA_real_, NA_real_), 4),
      data_types    = "nccnccnccncc"
    ),
    cn1 = list(
      long_names = c(
        "cn1_hrly_batvol_sensors_transm_avg_voltage",
        "cn1_hrly_batvol_sensors_transm_avg_voltage_qc_quality_code",
        "cn1_hrly_batvol_sensors_transm_avg_voltage_flag_quality_code",
        "cn1_hrly_batvol_full_load_avg_voltage",
        "cn1_hrly_batvol_full_load_avg_voltage_qc_quality_code",
        "cn1_hrly_batvol_full_load_avg_voltage_flag_quality_code",
        "cn1_hrly_batvol_datalogger_avg_voltage",
        "cn1_hrly_batvol_datalogger_avg_voltage_qc_quality_code",
        "cn1_hrly_batvol_datalogger_avg_voltage_flag_quality_code"
      ),
      field_lengths = c(4, 1, 1, 4, 1, 1, 4, 1, 1),
      scale_factors = rep(c(10, NA_real_, NA_real_), 3),
      data_types    = "nccnccncc"
    ),
    cn2 = list(
      long_names = c(
        "cn2_hrly_diagnostic_equipment_temp",
        "cn2_hrly_diagnostic_equipment_temp_qc_quality_code",
        "cn2_hrly_diagnostic_equipment_temp_flag_quality_code",
        "cn2_hrly_diagnostic_geonor_inlet_temp",
        "cn2_hrly_diagnostic_geonor_inlet_temp_qc_quality_code",
        "cn2_hrly_diagnostic_geonor_inlet_temp_flag_quality_code",
        "cn2_hrly_diagnostic_datalogger_opendoor_time",
        "cn2_hrly_diagnostic_datalogger_opendoor_time_qc_quality_code",
        "cn2_hrly_diagnostic_datalogger_opendoor_time_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 5, 1, 1, 2, 1, 1),
      scale_factors = c(rep(c(10, NA_real_, NA_real_), 2), 1, NA_real_, NA_real_),
      data_types    = "nccnccncc"
    ),
    cn3 = list(
      long_names = c(
        "cn3_hrly_diagnostic_reference_resistor_avg_resistance",
        "cn3_hrly_diagnostic_reference_resistor_avg_resistance_qc_quality_code",
        "cn3_hrly_diagnostic_reference_resistor_avg_resistance_flag_quality_code",
        "cn3_hrly_diagnostic_datalogger_signature_id",
        "cn3_hrly_diagnostic_datalogger_signature_id_qc_quality_code",
        "cn3_hrly_diagnostic_datalogger_signature_id_flag_quality_code"
      ),
      field_lengths = c(6, 1, 1, 6, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nccncc"
    ),
    cn4 = list(
      long_names = c(
        "cn4_hrly_diagnostic_liq_precip_gauge_flag_bit",
        "cn4_hrly_diagnostic_liq_precip_gauge_flag_bit_qc_quality_code",
        "cn4_hrly_diagnostic_liq_precip_gauge_flag_bit_flag_quality_code",
        "cn4_hrly_diagnostic_doorflag_field",
        "cn4_hrly_diagnostic_doorflag_field_qc_quality_code",
        "cn4_hrly_diagnostic_doorflag_field_flag_quality_code",
        "cn4_hrly_diagnostic_forward_transmitter_rf_power",
        "cn4_hrly_diagnostic_forward_transmitter_rf_power_qc_quality_code",
        "cn4_hrly_diagnostic_forward_transmitter_rf_power_flag_quality_code",
        "cn4_hrly_diagnostic_reflected_transmitter_rf_power",
        "cn4_hrly_diagnostic_reflected_transmitter_rf_power_qc_quality_code",
        "cn4_hrly_diagnostic_reflected_transmitter_rf_power_flag_quality_code"
      ),
      field_lengths = c(1, 1, 1, 1, 1, 1, 3, 1, 1, 3, 1, 1),
      scale_factors = c(rep(NA_real_, 6), 10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "ccccccnccncc"
    ),
    cr1 = list(
      long_names = c(
        "cr1_control_section_datalogger_version_number",
        "cr1_control_section_datalogger_version_number_qc_quality_code",
        "cr1_control_section_datalogger_version_number_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1),
      scale_factors = c(1000, NA_real_, NA_real_),
      data_types    = "ncc"
    ),
    ct1 = list(
      long_names = c(
        "ct1_subhrly_temp_avg_air_temp",
        "ct1_subhrly_temp_avg_air_temp_qc_quality_code",
        "ct1_subhrly_temp_avg_air_temp_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_),
      data_types    = "ncc"
    ),
    cu1 = list(
      long_names = c(
        "cu1_hrly_temp_avg_air_temp",
        "cu1_hrly_temp_avg_air_temp_qc_quality_code",
        "cu1_hrly_temp_avg_air_temp_flag_quality_code",
        "cu1_hrly_temp_avg_air_temp_st_dev",
        "cu1_hrly_temp_avg_air_temp_st_dev_qc_quality_code",
        "cu1_hrly_temp_avg_air_temp_st_dev_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 4, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nccncc"
    ),
    cv1 = list(
      long_names = c(
        "cv1_hrly_temp_min_air_temp",
        "cv1_hrly_temp_min_air_temp_qc_quality_code",
        "cv1_hrly_temp_min_air_temp_flag_quality_code",
        "cv1_hrly_temp_min_air_temp_time",
        "cv1_hrly_temp_min_air_temp_time_qc_quality_code",
        "cv1_hrly_temp_min_air_temp_time_flag_quality_code",
        "cv1_hrly_temp_max_air_temp",
        "cv1_hrly_temp_max_air_temp_qc_quality_code",
        "cv1_hrly_temp_max_air_temp_flag_quality_code",
        "cv1_hrly_temp_max_air_temp_time",
        "cv1_hrly_temp_max_air_temp_time_qc_quality_code",
        "cv1_hrly_temp_max_air_temp_time_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 4, 1, 1, 5, 1, 1, 4, 1, 1),
      scale_factors = c(10, rep(NA_real_, 5), 10, rep(NA_real_, 5)),
      data_types    = "ncccccnccccc"
    ),
    cw1 = list(
      long_names = c(
        "cw1_subhrly_wetness_wet1_indicator",
        "cw1_subhrly_wetness_wet1_indicator_qc_quality_code",
        "cw1_subhrly_wetness_wet1_indicator_flag_quality_code",
        "cw1_subhrly_wetness_wet2_indicator",
        "cw1_subhrly_wetness_wet2_indicator_qc_quality_code",
        "cw1_subhrly_wetness_wet2_indicator_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 5, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nccncc"
    ),
    cx1 = list(
      long_names = c(
        "cx1_hourly_geonor_vib_wire_total_precip",
        "cx1_hourly_geonor_vib_wire_total_precip_qc_quality_code",
        "cx1_hourly_geonor_vib_wire_total_precip_flag_quality_code",
        "cx1_hourly_geonor_vib_wire_freq_avg_precip",
        "cx1_hourly_geonor_vib_wire_freq_avg_precip_qc_quality_code",
        "cx1_hourly_geonor_vib_wire_freq_avg_precip_flag_quality_code",
        "cx1_hourly_geonor_vib_wire_freq_min_precip",
        "cx1_hourly_geonor_vib_wire_freq_min_precip_qc_quality_code",
        "cx1_hourly_geonor_vib_wire_freq_min_precip_flag_quality_code",
        "cx1_hourly_geonor_vib_wire_freq_max_precip",
        "cx1_hourly_geonor_vib_wire_freq_max_precip_qc_quality_code",
        "cx1_hourly_geonor_vib_wire_freq_max_precip_flag_quality_code"
      ),
      field_lengths = c(6, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_, rep(c(1, NA_real_, NA_real_), 3)),
      data_types    = "nccnccnccncc"
    ),
    co1 = list(
      long_names = c(
        "co1_network_metadata_climate_division_number",
        "co1_network_metadata_utc_lst_time_conversion"
      ),
      field_lengths = c(2, 3),
      scale_factors = c(1, 1),
      data_types    = "nn"
    ),
    co2 = list(
      long_names = c(
        "co2_us_network_cooperative_element_id",
        "co2_us_network_cooperative_time_offset"
      ),
      field_lengths = c(3, 5),
      scale_factors = c(NA_real_, 10),
      data_types    = "cn"
    ),
    ed1 = list(
      long_names = c(
        "ed1_runway_vis_range_obs_direction_angle",
        "ed1_runway_vis_range_obs_runway_designator_code",
        "ed1_runway_vis_range_obs_vis_dimension",
        "ed1_runway_vis_range_obs_quality_code"
      ),
      field_lengths = c(2, 1, 4, 1),
      scale_factors = c(0.1, NA_real_, 1, NA_real_),
      data_types    = "ncnc"
    ),
    ga1 = list(
      long_names = c(
        "ga1_sky_cover_layer_coverage_code",
        "ga1_sky_cover_layer_coverage_quality_code",
        "ga1_sky_cover_layer_base_height",
        "ga1_sky_cover_layer_base_height_quality_code",
        "ga1_sky_cover_layer_cloud_type",
        "ga1_sky_cover_layer_cloud_type_quality_code"
      ),
      field_lengths = c(2, 1, 6, 1, 2, 1),
      scale_factors = c(NA_real_, NA_real_, 1, NA_real_, NA_real_, NA_real_),
      data_types    = "ccnccc"
    ),
    gd1 = list(
      long_names = c(
        "gd1_sky_cover_summation_state_coverage_1",
        "gd1_sky_cover_summation_state_coverage_2",
        "gd1_sky_cover_summation_state_coverage_quality_code",
        "gd1_sky_cover_summation_state_height",
        "gd1_sky_cover_summation_state_height_quality_code",
        "gd1_sky_cover_summation_state_characteristic_code"
      ),
      field_lengths = c(1, 2, 1, 6, 1, 1),
      scale_factors = c(NA_real_, NA_real_, NA_real_, 1, NA_real_, NA_real_),
      data_types    = "cccncc"
    ),
    gf1 = list(
      long_names = c(
        "gf1_sky_condition_obs_total_coverage",
        "gf1_sky_condition_obs_total_opaque_coverage",
        "gf1_sky_condition_obs_total_coverage_quality_code",
        "gf1_sky_condition_obs_total_lowest_cloud_cover",
        "gf1_sky_condition_obs_total_lowest_cloud_cover_quality_code",
        "gf1_sky_condition_obs_low_cloud_genus",
        "gf1_sky_condition_obs_low_cloud_genus_quality_code",
        "gf1_sky_condition_obs_lowest_cloud_base_height",
        "gf1_sky_condition_obs_lowest_cloud_base_height_quality_code",
        "gf1_sky_condition_obs_mid_cloud_genus",
        "gf1_sky_condition_obs_mid_cloud_genus_quality_code",
        "gf1_sky_condition_obs_high_cloud_genus",
        "gf1_sky_condition_obs_high_cloud_genus_quality_code"
      ),
      field_lengths = c(2, 2, 1, 2, 1, 2, 1, 5, 1, 2, 1, 2, 1),
      scale_factors = c(rep(NA_real_, 7), 1, rep(NA_real_, 5)),
      data_types    = "cccccccnccccc"
    ),
    gg1 = list(
      long_names = c(
        "gg1_below_stn_cloud_layer_coverage",
        "gg1_below_stn_cloud_layer_coverage_quality_code",
        "gg1_below_stn_cloud_layer_top_height",
        "gg1_below_stn_cloud_layer_top_height_quality_code",
        "gg1_below_stn_cloud_layer_type",
        "gg1_below_stn_cloud_layer_type_quality_code",
        "gg1_below_stn_cloud_layer_top",
        "gg1_below_stn_cloud_layer_top_quality_code"
      ),
      field_lengths = c(2, 1, 5, 1, 2, 1, 2, 1),
      scale_factors = c(NA_real_, NA_real_, 1, rep(NA_real_, 5)),
      data_types    = "ccnccccc"
    ),
    gh1 = list(
      long_names = c(
        "gh1_hrly_solar_rad_hrly_avg_solarad",
        "gh1_hrly_solar_rad_hrly_avg_solarad_qc_quality_code",
        "gh1_hrly_solar_rad_hrly_avg_solarad_flag_quality_code",
        "gh1_hrly_solar_rad_min_solarad",
        "gh1_hrly_solar_rad_min_solarad_qc_quality_code",
        "gh1_hrly_solar_rad_min_solarad_flag_quality_code",
        "gh1_hrly_solar_rad_max_solarad",
        "gh1_hrly_solar_rad_max_solarad_qc_quality_code",
        "gh1_hrly_solar_rad_max_solarad_flag_quality_code",
        "gh1_hrly_solar_rad_std_dev_solarad",
        "gh1_hrly_solar_rad_std_dev_solarad_qc_quality_code",
        "gh1_hrly_solar_rad_std_dev_solarad_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 5, 1, 1, 5, 1, 1, 5, 1, 1),
      scale_factors = rep(c(10, NA_real_, NA_real_), 4),
      data_types    = "nccnccnccncc"
    ),
    gj1 = list(
      long_names = c(
        "gj1_sunshine_obs_duration",
        "gj1_sunshine_obs_duration_quality_code"
      ),
      field_lengths = c(4, 1),
      scale_factors = c(1, NA_real_),
      data_types    = "nc"
    ),
    gk1 = list(
      long_names = c(
        "gk1_sunshine_obs_pct_possible_sunshine",
        "gk1_sunshine_obs_pct_possible_quality_code"
      ),
      field_lengths = c(3, 1),
      scale_factors = c(1, NA_real_),
      data_types    = "nc"
    ),
    gl1 = list(
      long_names = c(
        "gl1_sunshine_obs_duration",
        "gl1_sunshine_obs_duration_quality_code"
      ),
      field_lengths = c(5, 1),
      scale_factors = c(1, NA_real_),
      data_types    = "nc"
    ),
    gm1 = list(
      long_names = c(
        "gm1_solar_irradiance_time_period",
        "gm1_solar_irradiance_global_irradiance",
        "gm1_solar_irradiance_global_irradiance_data_flag",
        "gm1_solar_irradiance_global_irradiance_quality_code",
        "gm1_solar_irradiance_direct_beam_irradiance",
        "gm1_solar_irradiance_direct_beam_irradiance_data_flag",
        "gm1_solar_irradiance_direct_beam_irradiance_quality_code",
        "gm1_solar_irradiance_diffuse_irradiance",
        "gm1_solar_irradiance_diffuse_irradiance_data_flag",
        "gm1_solar_irradiance_diffuse_irradiance_quality_code",
        "gm1_solar_irradiance_uvb_global_irradiance",
        "gm1_solar_irradiance_uvb_global_irradiance_data_flag",
        "gm1_solar_irradiance_uvb_global_irradiance_quality_code"
      ),
      field_lengths = c(4, 4, 2, 1, 4, 2, 1, 4, 2, 1, 4, 1),
      scale_factors = c(1, 1, NA_real_, NA_real_, 1, NA_real_, NA_real_, 1, NA_real_, NA_real_, 1, NA_real_),
      data_types    = "nnccnccnccnc"
    ),
    gn1 = list(
      long_names = c(
        "gn1_solar_rad_time_period",
        "gn1_solar_rad_upwelling_global_solar_rad",
        "gn1_solar_rad_upwelling_global_solar_rad_quality_code",
        "gn1_solar_rad_downwelling_thermal_ir_rad",
        "gn1_solar_rad_downwelling_thermal_ir_rad_quality_code",
        "gn1_solar_rad_upwelling_thermal_ir_rad",
        "gn1_solar_rad_upwelling_thermal_ir_rad_quality_code",
        "gn1_solar_rad_par",
        "gn1_solar_rad_par_quality_code",
        "gn1_solar_rad_solar_zenith_angle",
        "gn1_solar_rad_solar_zenith_angle_quality_code"
      ),
      field_lengths = c(4, 4, 2, 1, 4, 2, 1, 4, 2, 1, 4, 1),
      scale_factors = c(1, 1, NA_real_, NA_real_, 1, NA_real_, NA_real_, 1, NA_real_, NA_real_, 1, NA_real_),
      data_types    = "nnccnccnccnc"
    ),
    go1 = list(
      long_names = c(
        "go1_net_solar_rad_time_period",
        "go1_net_solar_rad_net_solar_radiation",
        "go1_net_solar_rad_net_solar_radiation_quality_code",
        "go1_net_solar_rad_net_ir_radiation",
        "go1_net_solar_rad_net_ir_radiation_quality_code",
        "go1_net_solar_rad_net_radiation",
        "go1_net_solar_rad_net_radiation_quality_code"
      ),
      field_lengths = c(4, 4, 1, 4, 1, 4, 1),
      scale_factors = c(1, 1, NA_real_, 1, NA_real_, 1, NA_real_),
      data_types    = "nncncnc"
    ),
    gp1 = list(
      long_names = c(
        "gp1_modeled_solar_irradiance_data_time_period",
        "gp1_modeled_solar_irradiance_global_horizontal",
        "gp1_modeled_solar_irradiance_global_horizontal_src_flag",
        "gp1_modeled_solar_irradiance_global_horizontal_uncertainty",
        "gp1_modeled_solar_irradiance_direct_normal",
        "gp1_modeled_solar_irradiance_direct_normal_src_flag",
        "gp1_modeled_solar_irradiance_direct_normal_uncertainty",
        "gp1_modeled_solar_irradiance_diffuse_normal",
        "gp1_modeled_solar_irradiance_diffuse_normal_src_flag",
        "gp1_modeled_solar_irradiance_diffuse_normal_uncertainty",
        "gp1_modeled_solar_irradiance_diffuse_horizontal",
        "gp1_modeled_solar_irradiance_diffuse_horizontal_src_flag",
        "gp1_modeled_solar_irradiance_diffuse_horizontal_uncertainty"
      ),
      field_lengths = c(4, 4, 2, 3, 4, 2, 3, 4, 2, 3),
      scale_factors = c(1, 1, NA_real_, 1, 1, NA_real_, 1, 1, NA_real_, 1),
      data_types    = "nncnncnncn"
    ),
    gq1 = list(
      long_names = c(
        "gq1_hrly_solar_angle_time_period",
        "gq1_hrly_solar_angle_mean_zenith_angle",
        "gq1_hrly_solar_angle_mean_zenith_angle_quality_code",
        "gq1_hrly_solar_angle_mean_azimuth_angle",
        "gq1_hrly_solar_angle_mean_azimuth_angle_quality_code"
      ),
      field_lengths = c(4, 4, 1, 4, 1),
      scale_factors = c(1, 10, NA_real_, 10, NA_real_),
      data_types    = "nncnc"
    ),
    gr1 = list(
      long_names = c(
        "gr1_hrly_extraterrestrial_rad_time_period",
        "gr1_hrly_extraterrestrial_rad_horizontal",
        "gr1_hrly_extraterrestrial_rad_horizontal_quality_code",
        "gr1_hrly_extraterrestrial_rad_normal",
        "gr1_hrly_extraterrestrial_rad_normal_quality_code"
      ),
      field_lengths = c(4, 4, 1, 4, 1),
      scale_factors = c(1, 1, NA_real_, 1, NA_real_),
      data_types    = "nncnc"
    ),
    hl1 = list(
      long_names = c(
        "hl1_hail_size",
        "hl1_hail_size_quality_code"
      ),
      field_lengths = c(3, 1),
      scale_factors = c(10, NA),
      data_types    = "nc"
    ),
    ia1 = list(
      long_names = c(
        "ia1_ground_surface_obs_code",
        "ia1_ground_surface_obs_code_quality_code"
      ),
      field_lengths = c(2, 1),
      scale_factors = c(NA_real_, NA_real_),
      data_types    = "cc"
    ),
    ia2 = list(
      long_names = c(
        "ia2_ground_surface_obs_min_temp_time_period",
        "ia2_ground_surface_obs_min_temp",
        "ia2_ground_surface_obs_min_temp_quality_code"
      ),
      field_lengths = c(3, 5, 1),
      scale_factors = c(10, 10, NA_real_),
      data_types    = "nnc"
    ),
    ib1 = list(
      long_names = c(
        "ib1_hrly_surface_temp",
        "ib1_hrly_surface_temp_qc_quality_code",
        "ib1_hrly_surface_temp_flag_quality_code",
        "ib1_hrly_surface_min_temp",
        "ib1_hrly_surface_min_temp_qc_quality_code",
        "ib1_hrly_surface_min_temp_flag_quality_code",
        "ib1_hrly_surface_max_temp",
        "ib1_hrly_surface_max_temp_qc_quality_code",
        "ib1_hrly_surface_max_temp_flag_quality_code",
        "ib1_hrly_surface_std_temp",
        "ib1_hrly_surface_std_temp_qc_quality_code",
        "ib1_hrly_surface_std_temp_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 5, 1, 1, 5, 1, 1, 4, 1, 1),
      scale_factors = rep(c(10, NA_real_, NA_real_), 4),
      data_types    = "nccnccnccncc"
    ),
    ib2 = list(
      long_names = c(
        "ib2_hrly_surface_temp_sb",
        "ib2_hrly_surface_temp_sb_qc_quality_code",
        "ib2_hrly_surface_temp_sb_flag_quality_code",
        "ib2_hrly_surface_temp_sb_std",
        "ib2_hrly_surface_temp_sb_std_qc_quality_code",
        "ib2_hrly_surface_temp_sb_std_flag_quality_code"
      ),
      field_lengths = c(5, 1, 1, 4, 1, 1),
      scale_factors = c(10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nccncc"
    ),
    ic1 = list(
      long_names = c(
        "ic1_grnd_surface_obs_pan_evap_time_period",
        "ic1_grnd_surface_obs_pan_evap_wind",
        "ic1_grnd_surface_obs_pan_evap_wind_condition_code",
        "ic1_grnd_surface_obs_pan_evap_wind_quality_code",
        "ic1_grnd_surface_obs_pan_evap_data",
        "ic1_grnd_surface_obs_pan_evap_data_condition_code",
        "ic1_grnd_surface_obs_pan_evap_data_quality_code",
        "ic1_grnd_surface_obs_pan_max_water_data",
        "ic1_grnd_surface_obs_pan_max_water_data_condition_code",
        "ic1_grnd_surface_obs_pan_max_water_data_quality_code",
        "ic1_grnd_surface_obs_pan_min_water_data",
        "ic1_grnd_surface_obs_pan_min_water_data_condition_code",
        "ic1_grnd_surface_obs_pan_min_water_data_quality_code"
      ),
      field_lengths = c(2, 4, 1, 1, 3, 1, 1, 4, 1, 1, 4, 1, 1),
      scale_factors = c(1, 1, NA_real_, NA_real_, 100, NA_real_, NA_real_, 10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nnccnccnccncc"
    ),
    ka1 = list(
      long_names = c(
        "ka1_extreme_air_temp_time_period",
        "ka1_extreme_air_temp_code",
        "ka1_extreme_air_temp_high_or_low",
        "ka1_extreme_air_temp_high_or_low_quality_code"
      ),
      field_lengths = c(3, 1, 5, 1),
      scale_factors = c(10, NA_real_, 10, NA_real_),
      data_types    = "ncnc"
    ),
    kb1 = list(
      long_names = c(
        "kb1_avg_air_temp_time_period",
        "kb1_avg_air_temp_code",
        "kb1_avg_air_temp_air_temp",
        "kb1_avg_air_temp_air_temp_quality_code"
      ),
      field_lengths = c(3, 1, 5, 1),
      scale_factors = c(10, NA_real_, 10, NA_real_),
      data_types    = "ncnc"
    ),
    kc1 = list(
      long_names = c(
        "kc1_extreme_air_temp_monthly_code",
        "kc1_extreme_air_temp_monthly_condition_code",
        "kc1_extreme_air_temp_monthly_temp",
        "kc1_extreme_air_temp_monthly_date",
        "kc1_extreme_air_temp_monthly_temp_quality_code"
      ),
      field_lengths = c(1, 1, 5, 6, 1),
      scale_factors = c(NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "ccncc"
    ),
    kd1 = list(
      long_names = c(
        "kd1_heat_cool_deg_days_time_period",
        "kd1_heat_cool_deg_days_code",
        "kd1_heat_cool_deg_days_value",
        "kd1_heat_cool_deg_days_quality_code"
      ),
      field_lengths = c(3, 1, 4, 1),
      scale_factors = c(1, NA_real_, 1, NA_real_),
      data_types    = "ncnc"
    ),
    ke1 = list(
      long_names = c(
        "ke1_extreme_temp_number_days_max_32f_or_lower",
        "ke1_extreme_temp_number_days_max_32f_or_lower_quality_code",
        "ke1_extreme_temp_number_days_max_90f_or_higher",
        "ke1_extreme_temp_number_days_max_90f_or_higher_quality_code",
        "ke1_extreme_temp_number_days_min_32f_or_lower",
        "ke1_extreme_temp_number_days_min_32f_or_lower_quality_code",
        "ke1_extreme_temp_number_days_min_0f_or_lower",
        "ke1_extreme_temp_number_days_min_0f_or_lower_quality_code"
      ),
      field_lengths = c(2, 1, 2, 1, 2, 1, 2, 1),
      scale_factors = c(1, NA_real_, 1, NA_real_, 1, NA_real_, 1, NA_real_),
      data_types    = "ncncncnc"
    ),
    kf1 = list(
      long_names = c(
        "kf1_hrly_calc_temp",
        "kf1_hrly_calc_temp_quality_code"
      ),
      field_lengths = c(5, 1),
      scale_factors = c(10, NA_real_),
      data_types    = "nc"
    ),
    kg1 = list(
      long_names = c(
        "kg1_avg_dp_wb_temp_time_period",
        "kg1_avg_dp_wb_temp_code",
        "kg1_avg_dp_wb_temp",
        "kg1_avg_dp_wb_temp_derived_code",
        "kg1_avg_dp_wb_temp_quality_code"
      ),
      field_lengths = c(3, 1, 5, 1, 1),
      scale_factors = c(1, NA_real_, 100, NA_real_, NA_real_),
      data_types    = "ncncc"
    ),
    ma1 = list(
      long_names = c(
        "ma1_atmos_p_obs_altimeter_setting_rate",
        "ma1_atmos_p_obs_altimeter_quality_code",
        "ma1_atmos_p_obs_stn_pressure_rate",
        "ma1_atmos_p_obs_stn_pressure_rate_quality_code"
      ),
      field_lengths = c(5, 1, 5, 1),
      scale_factors = c(10, NA_real_, 10, NA_real_),
      data_types    = "ncnc"
    ),
    md1 = list(
      long_names = c(
        "md1_atmos_p_change_tendency_code",
        "md1_atmos_p_change_tendency_code_quality_code",
        "md1_atmos_p_change_3_hr_quantity",
        "md1_atmos_p_change_3_hr_quantity_quality_code",
        "md1_atmos_p_change_24_hr_quantity",
        "md1_atmos_p_change_24_hr_quantity_quality_code"
      ),
      field_lengths = c(1, 1, 3, 1, 4, 1),
      scale_factors = c(NA_real_, NA_real_, 10, NA_real_, 10, NA_real_),
      data_types    = "ccncnc"
    ),
    me1 = list(
      long_names = c(
        "me1_geopotential_hgt_isobaric_lvl_code",
        "me1_geopotential_hgt_isobaric_lvl_height",
        "me1_geopotential_hgt_isobaric_lvl_height_quality_code"
      ),
      field_lengths = c(1, 4, 1),
      scale_factors = c(NA_real_, 1, NA_real_),
      data_types    = "cnc"
    ),
    mf1 = list(
      long_names = c(
        "mf1_atmos_p_obs_stp_avg_stn_pressure_day",
        "mf1_atmos_p_obs_stp_avg_stn_pressure_day_quality_code",
        "mf1_atmos_p_obs_stp_avg_sea_lvl_pressure_day",
        "mf1_atmos_p_obs_stp_avg_sea_lvl_pressure_day_quality_code"
      ),
      field_lengths = c(5, 1, 5, 1),
      scale_factors = c(10, NA_real_, 10, NA_real_),
      data_types    = "ncnc"
    ),
    mg1 = list(
      long_names = c(
        "mg1_atmos_p_obs_avg_stn_pressure_day",
        "mg1_atmos_p_obs_avg_stn_pressure_day_quality_code",
        "mg1_atmos_p_obs_avg_sea_lvl_pressure_day",
        "mg1_atmos_p_obs_avg_sea_lvl_pressure_day_quality_code"
      ),
      field_lengths = c(5, 1, 5, 1),
      scale_factors = c(10, NA_real_, 10, NA_real_),
      data_types    = "ncnc"
    ),
    mh1 = list(
      long_names = c(
        "mh1_atmos_p_obs_avg_stn_pressure_month",
        "mh1_atmos_p_obs_avg_stn_pressure_month_quality_code",
        "mh1_atmos_p_obs_avg_sea_lvl_pressure_month",
        "mh1_atmos_p_obs_avg_sea_lvl_pressure_month_quality_code"
      ),
      field_lengths = c(5, 1, 5, 1),
      scale_factors = c(10, NA_real_, 10, NA_real_),
      data_types    = "ncnc"
    ),
    mk1 = list(
      long_names = c(
        "mk1_atmos_p_obs_max_sea_lvl_pressure_month",
        "mk1_atmos_p_obs_max_sea_lvl_pressure_date_time",
        "mk1_atmos_p_obs_max_sea_lvl_pressure_quality_code",
        "mk1_atmos_p_obs_min_sea_lvl_pressure_month",
        "mk1_atmos_p_obs_min_sea_lvl_pressure_date_time",
        "mk1_atmos_p_obs_min_sea_lvl_pressure_quality_code"
      ),
      field_lengths = c(5, 6, 1, 5, 6, 1),
      scale_factors = c(10, NA_real_, NA_real_, 10, NA_real_, NA_real_),
      data_types    = "nccncc"
    ),
    mv1 = list(
      long_names = c(
        "mv1_present_weather_obs_condition_code",
        "mv1_present_weather_obs_condition_code_quality_code"
      ),
      field_lengths = c(2, 1),
      scale_factors = c(NA_real_, NA_real_),
      data_types    = "cc"
    ),
    mw1 = list(
      long_names = c(
        "mw1_present_weather_obs_manual_occurrence_condition_code",
        "mw1_present_weather_obs_manual_occurrence_condition_code_quality_code"
      ),
      field_lengths = c(2, 1),
      scale_factors = c(NA_real_, NA_real_),
      data_types    = "cc"
    ),
    oa1 = list(
      long_names = c(
        "oa1_suppl_wind_obs_type",
        "oa1_suppl_wind_obs_time_period",
        "oa1_suppl_wind_obs_speed_rate",
        "oa1_suppl_wind_obs_speed_rate_quality_code"
      ),
      field_lengths = c(1, 2, 4, 1),
      scale_factors = c(NA_real_, 1, 10, NA_real_),
      data_types    = "cnnc"
    ),
    ob1 = list(
      long_names = c(
        "ob1_hly_subhrly_wind_avg_time_period",
        "ob1_hly_subhrly_wind_max_gust",
        "ob1_hly_subhrly_wind_max_gust_quality_code",
        "ob1_hly_subhrly_wind_max_gust_flag",
        "ob1_hly_subhrly_wind_max_dir",
        "ob1_hly_subhrly_wind_max_dir_quality_code",
        "ob1_hly_subhrly_wind_max_dir_flag",
        "ob1_hly_subhrly_wind_max_stdev",
        "ob1_hly_subhrly_wind_max_stdev_quality_code",
        "ob1_hly_subhrly_wind_max_stdev_flag",
        "ob1_hly_subhrly_wind_max_dir_stdev",
        "ob1_hly_subhrly_wind_max_dir_stdev_quality_code",
        "ob1_hly_subhrly_wind_max_dir_stdev_flag"
      ),
      field_lengths = c(3, 4, 1, 1, 3, 1, 1, 5, 1, 1, 5, 1, 1),
      scale_factors = c(1, 10, NA_real_, NA_real_, 1, NA_real_, NA_real_, 100, NA_real_, NA_real_, 100, NA_real_, NA_real_),
      data_types    = "nnccnccnccncc"
    ),
    oc1 = list(
      long_names = c(
        "oc1_wind_gust_obs_speed_rate",
        "oc1_wind_gust_obs_speed_rate_quality_code"
      ),
      field_lengths = c(4, 1),
      scale_factors = c(10, NA_real_),
      data_types    = "nc"
    ),
    oe1 = list(
      long_names = c(
        "oe1_summary_of_day_wind_obs_type",
        "oe1_summary_of_day_wind_obs_time_period",
        "oe1_summary_of_day_wind_obs_speed_rate",
        "oe1_summary_of_day_wind_obs_dir",
        "oe1_summary_of_day_wind_obs_time_occurrence",
        "oe1_summary_of_day_wind_obs_quality_code"
      ),
      field_lengths = c(1, 2, 5, 3, 4, 1),
      scale_factors = c(NA_real_, 1, 100, 1, 10, NA_real_),
      data_types    = "cnnnnc"
    ),
    rh1 = list(
      long_names = c(
        "rh1_relative_humidity_time_period",
        "rh1_relative_humidity_code",
        "rh1_relative_humidity_percentage",
        "rh1_relative_humidity_derived_code",
        "rh1_relative_humidity_quality_code"
      ),
      field_lengths = c(3, 1, 3, 1, 1),
      scale_factors = c(1, NA_real_, 1, NA_real_, NA_real_),
      data_types    = "ncncc"
    ),
    sa1 = list(
      long_names = c(
        "sa1_sea_surf_temp",
        "sa1_sea_surf_temp_quality_code"
      ),
      field_lengths = c(4, 1),
      scale_factors = c(10, NA_real_),
      data_types    = "nc"
    ),
    st1 = list(
      long_names = c(
        "st1_soil_temp_type",
        "st1_soil_temp_soil_temp",
        "st1_soil_temp_soil_temp_quality_code",
        "st1_soil_temp_depth",
        "st1_soil_temp_depth_quality_code",
        "st1_soil_temp_soil_cover",
        "st1_soil_temp_soil_cover_quality_code",
        "st1_soil_temp_sub_plot",
        "st1_soil_temp_sub_plot_quality_code"
      ),
      field_lengths = c(1, 5, 1, 4, 1, 2, 1, 1, 1),
      scale_factors = c(NA_real_, 10, NA_real_, 10, NA_real_, NA_real_, NA_real_, NA_real_, NA_real_),
      data_types    = "cncnccccc"
    ),
    ua1 = list(
      long_names = c(
        "ua1_wave_meas_method_code",
        "ua1_wave_meas_wave_period_quantity",
        "ua1_wave_meas_wave_height_dimension",
        "ua1_wave_meas_quality_code",
        "ua1_wave_meas_sea_state_code",
        "ua1_wave_meas_sea_state_code_quality_code"
      ),
      field_lengths = c(1, 2, 3, 1, 2, 1),
      scale_factors = c(NA_real_, 1, 10, NA_real_, NA_real_, NA_real_),
      data_types    = "cnnccc"
    ),
    ug1 = list(
      long_names = c(
        "ug1_wave_meas_primary_swell_time_period",
        "ug1_wave_meas_primary_swell_height_dimension",
        "ug1_wave_meas_primary_swell_dir_angle",
        "ug1_wave_meas_primary_swell_quality_code"
      ),
      field_lengths = c(2, 3, 3, 1),
      scale_factors = c(1, 10, 1, NA_real_),
      data_types    = "nnnc"
    ),
    ug2 = list(
      long_names = c(
        "ug2_wave_meas_secondary_swell_time_period",
        "ug2_wave_meas_secondary_swell_height_dimension",
        "ug2_wave_meas_secondary_swell_dir_angle",
        "ug2_wave_meas_secondary_swell_quality_code"
      ),
      field_lengths = c(2, 3, 3, 1),
      scale_factors = c(1, 10, 1, NA_real_),
      data_types    = "nnnc"
    ),
    wa1 = list(
      long_names = c(
        "wa1_platform_ice_accr_source_code",
        "wa1_platform_ice_accr_thickness_dimension",
        "wa1_platform_ice_accr_tendency_code",
        "wa1_platform_ice_accr_quality_code"
      ),
      field_lengths = c(1, 3, 1, 1),
      scale_factors = c(NA_real_, 10, NA_real_, NA_real_),
      data_types    = "cncc"
    ),
    wd1 = list(
      long_names = c(
        "wd1_water_surf_ice_obs_edge_bearing_code",
        "wd1_water_surf_ice_obs_uniform_conc_rate",
        "wd1_water_surf_ice_obs_non_uniform_conc_rate",
        "wd1_water_surf_ice_obs_ship_rel_pos_code",
        "wd1_water_surf_ice_obs_ship_penetrability_code",
        "wd1_water_surf_ice_obs_ice_trend_code",
        "wd1_water_surf_ice_obs_development_code",
        "wd1_water_surf_ice_obs_growler_bergy_bit_pres_code",
        "wd1_water_surf_ice_obs_growler_bergy_bit_quantity",
        "wd1_water_surf_ice_obs_iceberg_quantity",
        "wd1_water_surf_ice_obs_quality_code"
      ),
      field_lengths = c(2, 3, 2, 1, 1, 1, 2, 1, 3, 3, 1),
      scale_factors = c(NA_real_, 1, NA_real_, NA_real_, NA_real_, NA_real_, NA_real_, NA_real_, 1, 1, NA_real_),
      data_types    = "cnccccccnnc"
    ),
    wg1 = list(
      long_names = c(
        "wg1_water_surf_ice_hist_obs_edge_distance",
        "wg1_water_surf_ice_hist_obs_edge_orient_code",
        "wg1_water_surf_ice_hist_obs_form_type_code",
        "wg1_water_surf_ice_hist_obs_nav_effect_code",
        "wg1_water_surf_ice_hist_obs_quality_code"
      ),
      field_lengths = c(2, 2, 2, 2, 2, 1),
      scale_factors = c(NA_real_, 1, NA_real_, NA_real_, NA_real_, NA_real_),
      data_types    = "cncccc"
    )
  )
}

field_categories <- function() {
  
  c(
    "AA1", "AB1", "AC1", "AD1", "AE1", "AG1", "AH1", "AI1", "AJ1",
    "AK1", "AL1", "AM1", "AN1", "AO1", "AP1", "AU1", "AW1", "AX1",
    "AY1", "AZ1", "CB1", "CF1", "CG1", "CH1", "CI1", "CN1", "CN2",
    "CN3", "CN4", "CR1", "CT1", "CU1", "CV1", "CW1", "CX1", "CO1",
    "CO2", "ED1", "GA1", "GD1", "GF1", "GG1", "GH1", "GJ1", "GK1",
    "GL1", "GM1", "GN1", "GO1", "GP1", "GQ1", "GR1", "HL1", "IA1",
    "IA2", "IB1", "IB2", "IC1", "KA1", "KB1", "KC1", "KD1", "KE1",
    "KF1", "KG1", "MA1", "MD1", "ME1", "MF1", "MG1", "MH1", "MK1",
    "MV1", "MW1", "OA1", "OB1", "OC1", "OE1", "RH1", "SA1", "ST1",
    "UA1", "UG1", "UG2", "WA1", "WD1", "WG1"
  ) %>% 
    tolower()
}

# Function for getting data from an additional data category
get_df_from_category <- function(category_key,
                                 field_lengths,
                                 scale_factor,
                                 data_types,
                                 add_data) {
  
  # Create a progress bar object
  pb <- 
    progress::progress_bar$new(
      format = "  processing :what [:bar] :percent",
      total  = nchar(data_types)
    )
  
  column_names <- paste0(category_key %>% tolower(), "_", seq(field_lengths))
  
  dtypes <- c()
  
  for (i in seq(nchar(data_types))) {
    
    dtypes <- 
      c(dtypes, ifelse(substr(data_types, i, i) == "n", "numeric", "character"))
  }
  
  data_strings <- 
    add_data %>%
    stringr::str_extract(paste0(category_key, ".*"))
  
  res_list <- list()
  
  for (i in seq(field_lengths)){
    
    if (i == 1) {
      substr_start <- 4
      substr_end <- substr_start + (field_lengths[i] - 1)
    } else {
      substr_start <- substr_end + 1
      substr_end <- substr_start + (field_lengths[i] - 1)
    }
    
    if (dtypes[i] == "numeric") {
      
      data_column <- rep(NA_real_, length(data_strings))
      
      for (j in seq(data_strings)) {
        
        if (!is.na(data_strings[j])) {
          
          data_column[j] <-
            (substr(data_strings[j], substr_start, substr_end) %>%
               as.numeric()) / scale_factor[i]
        }
      }
    }
    
    if (dtypes[i] == "character"){
      
      data_column <- rep(NA_character_, length(data_strings))
      
      for (j in seq(data_strings)) {
        
        if (!is.na(data_strings[j])) {
          data_column[j] <- 
            substr(data_strings[j], substr_start, substr_end)
        }
      }
    }
    
    res_list <- res_list %>% append(list(data_column))
    
    # Add tick to progress bar
    pb$tick(tokens = list(what = category_key))
  }
  
  names(res_list) <- column_names
  
  res_list %>% dplyr::as_tibble()
}

bind_additional_data <- function(data,
                                 add_data,
                                 category_key) {
  
  category_key <- tolower(category_key)
  
  category_params <- additional_data_fields()[[category_key]]
  
  additional_data <-
    get_df_from_category(
      category_key = toupper(category_key),
      field_lengths = category_params$field_lengths,
      scale_factor = category_params$scale_factors,
      data_types =  category_params$data_types,
      add_data = add_data
    )
  
  dplyr::bind_cols(data, additional_data)
}
