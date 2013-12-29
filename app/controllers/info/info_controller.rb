class Info::InfoController < ApplicationController
  before_action :set_cache_buster
  before_action :set_date_ampm
  before_action :collect_bp_entry_details
  before_action :collect_bp
  
  def home_page
  end
  
  
  def measuring_blood_pressure
  end
  
    def how_do_i_measure_my_blood_pressure
    end
  
    def when_should_i_measure_my_blood_pressure
    end
  
    def how_do_i_choose_a_blood_pressure_machine
    end
  
  
  def what_is_blood_pressure
  end
  
    def what_am_i_measuring
    end
    
    def what_do_the_numbers_mean
    end
    
    def what_is_the_normal_range_for_me
    end
  
    
  def treating_blood_pressure
  end
  
    def lifestyle_options
    end
    
      def diet
      end
      
      def exercise
      end
      
      def smoking
      end
      
    
    def complementary_therapy
    end
    
      def supplements
      end
      
      def acupuncture
      end
      
      def herbal
      end
      
    
    def medication
    end

      def when_is_medication_recommended
      end
      
      def why_do_i_need_to_take_more_than_one_medication
      end
      
      def how_can_i_reduce_the_risk_of_side_effects
      end
      
      def what_are_the_different_medication_options_for_me
      end
      
        def calcium_channel_blockers
        end
        
        def ace_inhibitors
        end
        
        def diuretics
        end
        
        def a2rbs
        end
        
        def beta_blockers
        end
  
end