module ClinicalTrials 
  class Parser

    attr_accessor :raw, :doc

    @@fields= %w(irb_number title summary contact_name contact_email contact_phone criteria status)

    def initialize(raw)
      @raw = raw
      @contents = {}
    end

    def doc
      @doc ||= Nokogiri::XML(@raw)
    end

    def study
      doc
    end

    def first_css_match(css)
      entity = doc.css(css).first
      entity ? entity.content : ""
    end

    def org_study_id
      first_css_match 'id_info org_study_id' || ""
    end

    def secondary_id
      first_css_match 'id_info secondary_id' || ""
    end

    def nct_id
      first_css_match 'id_info nct_id'  || ""
    end

    alias irb_number nct_id

    def title
      first_css_match 'brief_title' || ""
    end

    def official_title
      first_css_match 'official_title' || ""
    end

    def condition
      first_css_match 'condition' || ""
    end

    def summary
      first_css_match 'brief_summary textblock' || ""
    end

    def contact_name
      first_css_match 'overall_contact last_name' || ""
    end

    def contact_email
      first_css_match 'overall_contact email' || ""
    end

    def contact_phone
      first_css_match 'overall_contact phone' || ""
    end

    def status
      first_css_match 'overall_status' || ""
    end

    def criteria 
      EligibilityCleaner.format(doc.css('eligibility criteria textblock').first.content)
    end

    alias eligibility criteria
    # def inclusion_criteria
    #  #the inclusion criteria are the first half of the text block..
    #  eligibility.split("EXCLUSION CRITERIA")[0]
    # end
    # def exclusion_criteria
    #  #the exclusion criteria are the second half of the text block..
    #  "EXCLUSION CRITERIA:\n" + eligibility.split("EXCLUSION CRITERIA")[1]
    # end
    def dump
      @@fields.each { |field| @contents[field] = send(field) }                
      @contents
    end

    alias to_hash dump
  end
end
