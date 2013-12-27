class Info::MeasuringController < Info::InfoController
  before_action :set_cache_buster
  before_action :set_date_ampm
  before_action :collect_bp_entry_details, only: [:how_do_i_measure_my_blood_pressure, :when_should_i_measure_my_blood_pressure, :how_do_i_choose_a_blood_pressure_machine]
  before_action :collect_bp, only: [:how_do_i_measure_my_blood_pressure, :when_should_i_measure_my_blood_pressure, :how_do_i_choose_a_blood_pressure_machine]
  
  def how_do_i_measure_my_blood_pressure
  end
  
  def when_should_i_measure_my_blood_pressure
  end
  
  def how_do_i_choose_a_blood_pressure_machine
  end

end