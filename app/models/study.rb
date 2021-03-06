# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Study < Protocol
  validates :sponsor_name, :presence => true

  def classes
    return [ 'project' ] # for backward-compatibility
  end

  def populate_for_edit
    super
    self.build_research_types_info           unless self.research_types_info
    self.build_human_subjects_info           unless self.human_subjects_info
    self.build_vertebrate_animals_info       unless self.vertebrate_animals_info
    self.build_investigational_products_info unless self.investigational_products_info
    self.build_ip_patents_info               unless self.ip_patents_info
    self.setup_study_types
    self.setup_impact_areas
    self.setup_affiliations
  end
  
  def setup_study_types
    position = 1
    obj_names = StudyType::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      study_type = study_types.detect{|obj| obj.name == obj_name}
      study_type = study_types.build(:name => obj_name, :new => true) unless study_type
      study_type.position = position
      position += 1
    end

    study_types.sort!{|a, b| a.position <=> b.position}
  end

  def setup_impact_areas
    position = 1
    obj_names = ImpactArea::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      impact_area = impact_areas.detect{|obj| obj.name == obj_name}
      impact_area = impact_areas.build(:name => obj_name, :new => true) unless impact_area
      impact_area.position = position
      position += 1
    end
    impact_areas.sort!{|a, b| a.position <=> b.position}
  end
  
  def setup_affiliations
    position = 1
    obj_names = Affiliation::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      affiliation = affiliations.detect{|obj| obj.name == obj_name}
      affiliation = affiliations.build(:name => obj_name, :new => true) unless affiliation
      affiliation.position = position
      position += 1
    end

    affiliations.sort!{|a, b| a.position <=> b.position}
  end

end
