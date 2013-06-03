class Project < ActiveRecord::Base
  include ProjectCache
  include ProjectSearch
  include ProjectExporters
  extend  ProjectExporterHeaders
  include ActionView::Helpers::NumberHelper

  attr_accessible :title, :active, :capacity, :description, :year,
    :start_actual, :start_planned, :end_actual, :end_planned, :sector_comment,
    :is_commercial, :media_id, 
    :year_uncertain, :debt_uncertain, :line_of_credit,
    :is_cofinanced,
    # belongs_to fields
    :status, :verified, 
    :flow_type, :oda_like, :sector,
    #convoluted fields
    :donor, :owner, 
    :transactions, :transactions_attributes,
    :geopoliticals, :geopoliticals_attributes,
    :participating_organizations, :participating_organizations_attributes,
    :contacts, :contacts_attributes,
    :sources, :sources_attributes,
    :flow_class_attributes,
    :loan_detail_attributes,
    # for version control
    :accessories, :iteration,
    # hidden fields
    :verified_id, :sector_id,  :flow_type_id, :oda_like_id, :status_id,
    :donor_id, :owner_id, :intent_id, :crs_sector_id,
    :last_state

  before_save :set_verified_to_raw_if_null
  before_save :set_owner_to_aiddata_if_null
  # after_save :remake_scope_files
  # after_destroy :remake_scope_files

  # default_scope where("verified_id != ?", Verified.find_by_name("Raw").id)
  scope :past_stage_one, where("active = 't' AND verified_id != ?", Verified.find_by_name("Raw").id)
  
  def is_stage_one # for AidData Workflow filter -- "?" wasn't allowed by sunspot!
    ((verified.nil?) ||(verified.name == 'Raw' && active == true)) ? "Is Stage One" : "Is not Stage One"
  end
 

  def project_logger
    @@project_logger ||= Logger.new("#{Rails.root}/log/project.log")
  end


  def association_hash
    assoc_hash = {}
    class_name = self.class.name
    association_keys = class_name.constantize.reflections.keys
    association_keys.each do |assoc_sym|
      next if assoc_sym == :versions
      value = self.send(assoc_sym)
      ids = []
      if value.respond_to?(:map)
        ids = value.map {|item| item.id}
      else
        if value
          ids << value.id
        else
          ids << value
        end
      end
      assoc_hash[assoc_sym.to_s] = ids
    end
    assoc_hash
  end

  def attribute_hash
    att_hash = self.attributes
    att_hash.delete('last_state')
    att_hash
  end

  def full_hash
    association_hash.merge(attribute_hash)
  end

  def save_state
    self.assign_attributes({last_state: full_hash.to_yaml})
  end

  def association_changed?
    if YAML.load(last_state) == association_hash
      return false
    else
      return true
    end
  end

  def changes
    changes_hash = {}
    return changes_hash if last_state == nil
    last_hash = YAML.load(last_state)
    current_hash = full_hash
    current_hash.each_pair do |key, current_value|
      #unrelevant details
      next if key == 'updated_at' || key == 'iteration' || key == 'exports'
      if current_value != last_hash[key]
        changes_hash[key] = [last_hash[key], current_value]
      end
    end
    changes_hash
  end

  def remake_scope_files
    scope.each do |s|
      cache_files(s)
    end
  end 


  def increment_iteration # DUH, version was already taken by paper_trail
    iteration ||= 0
    iteration += 1
  end


  has_and_belongs_to_many :exports

  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :comments, allow_destroy: true


  has_paper_trail(meta: {accessories: :accessories})


  def accessories
    {transaction: transactions.each(&:attributes), 
      source: sources.each(&:attributes), 
      participating_organization: participating_organizations.each(&:attributes),
      contact: contacts.each(&:attributes),
      geopolitical: geopoliticals.each(&:attributes),
      flow_class: flow_class(&:attributes),
      loan_detail: loan_detail(&:attributes)
    }.to_json
  end

  validates :donor, presence: true

  def to_english(options={})
    exclude_title = options[:exclude_title] || false
    "#{exclude_title ? "" : "#{title}: "}" +
      "#{ usd_2009.present? && usd_2009 > 0 ? "$#{number_with_precision(usd_2009, precision: 2, delimiter: ",")}" : ""}" +
      (geopoliticals.blank? ? "" : " to #{country_name.to_sentence}" ) +
      (year.present? ? " in #{year}" : "")
  end

  # I'm adding string methods for these codes for Sunspot Facets
  CODES = %i{status verified intent crs_sector sector}
  CODES.each do |c|
    belongs_to c
    define_method "#{c}_name" do
      this_code = self.send(c)
      this_code.present? ? this_code.name : "Unset"
    end
  end

  # This is really the only one where the code also matters.
  def crs_sector_code
    crs_sector ? crs_sector.code : nil
  end

  belongs_to :flow_type
  def flow_type_name
    flow_type.present? ? flow_type.name : "Unset"
  end

  # 1/8/13 -- restructuring flow class             ~~~~~~~~~~~~~~~~
  #
  # Replacing oda_like with a double-code + arbitrated FlowClass

  def oda_like_name
    oda_like.present? ? oda_like.name : "Unset"
  end 

  # NEW:

  def oda_like=(new_oda_like)
    # first it tries round 1, then round 2. you can't set the master this way. 
    flow_class= FlowClass.find_or_create_by_project_id(id)
    if new_oda_like
      if flow_class.oda_like_1.nil?
        flow_class.oda_like_1_id=new_oda_like.id
      else
        flow_class.oda_like_2_id=new_oda_like.id
      end
    end

    flow_class.save
  end

  def oda_like(what_is_it=false)
    if what_is_it==false
      if flow_class && best_answer = flow_class.oda_like_master || flow_class.oda_like_2 || flow_class.oda_like_1
        best_answer
      else
        nil
      end
    else
      if flow_class
        if best_answer = flow_class.oda_like_master
          answer_type = "Arbitrated"
          [best_answer, answer_type]
        elsif best_answer = flow_class.oda_like_2 || flow_class.oda_like_1
          answer_type = "Single-coded"
          [best_answer, answer_type]
        else 
          nil
        end
      else
        nil
      end
    end
  end

  ############################################################
  # Flow Class Methods
  ############################################################
  def visible_flow_class
    oda_like(true) # to return [best_answer, answer_type]
  end

  def flow_class_arbitrated
    if flow_class && flow_class.oda_like_master
      flow_class.oda_like_master.name
    else
      "None"
    end
  end

  def flow_class_1
    if flow_class && flow_class.oda_like_1
      flow_class.oda_like_1.name
    else
      "None"
    end
  end

  def flow_class_2
    if flow_class && flow_class.oda_like_2
      flow_class.oda_like_2.name
    else
      "None"
    end
  end 

  has_one :flow_class, dependent: :destroy
  accepts_nested_attributes_for :flow_class

  ####################################################
  # Loan Detail Methods
  ####################################################

  # RDM 3/25/2013 "_band" methods for searching

  has_one :loan_detail, dependent: :destroy
  accepts_nested_attributes_for :loan_detail

  def loan_type
    if loan_detail.nil?
      "Unset"
    else
      loan_detail.loan_type
    end
  end

  def loan_type_name
    if loan_detail.nil? || loan_detail.loan_type.nil?
      ""
    else
      loan_detail.loan_type.name
    end
  end

  delegate  :grant_element, 
            :grace_period, 
            :maturity, 
            :interest_rate,
      to: :loan_detail, 
      allow_nil: true


  # could I metaprogram these _band methods in a graceful way?
  def interest_rate_band
    # don't use "%" -- it screws up the search URLs
    if (!loan_detail.nil?) && (m = loan_detail.interest_rate)
      if m <= 10
        "#{m} percent"
      elsif m > 10
        ">10 percent"
      end
    else
      "(None)"
    end
  end



  def maturity_band
    if (!loan_detail.nil?) && (m = loan_detail.maturity)
      if m < 5
        "0 to 5 years"
      elsif m >= 5 && m <=15
        "5 to 15 years"
      elsif m > 15
        ">15 years"
      end

    else
      "(None)"
    end
  end


  def grace_period_band
    if (!loan_detail.nil?) && (m = loan_detail.grace_period)
      if m <= 5
        "#{m} year#{ m != 1 ? 's' : ""}"
      elsif m > 5 && m <=10
        "6 to 10 years"
      elsif m > 10
        ">10 years"
      end
    else
      "(None)"
    end
  end

  def grant_element_band
    if (!loan_detail.nil?) && (m = loan_detail.grant_element)
      if m < 25
        "0 to 24 percent"
      elsif m >= 100
        "100 percent"
      elsif m >= 25 && m <= 50
        "25 to 50 percent"
      elsif m < 100 && m > 50
        "51 to 99 percent"
      end
    else
      "(None)"
    end
  end

  #
  #  End restructuring
  #




  belongs_to :donor, class_name: "Country"
  delegate :name, to: :donor, allow_nil: true, prefix: true

  belongs_to :owner, class_name: "Organization"
  delegate :name, to: :owner, allow_nil: true, prefix: true



  # project accessories
  has_many :geopoliticals, dependent: :destroy
  accepts_nested_attributes_for :geopoliticals, allow_destroy: true, :reject_if => proc { |a| a['recipient_id'].blank? }


  has_many :transactions, dependent: :destroy
  accepts_nested_attributes_for :transactions, allow_destroy: true, :reject_if => proc { |a| a['value'].blank? }


  has_many :contacts, dependent: :destroy  
  accepts_nested_attributes_for :contacts, allow_destroy: true, :reject_if => proc { |a| a['name'].blank? && a['position'].blank? && a['organization_id'].blank?}

  has_many :sources, dependent: :destroy
  accepts_nested_attributes_for :sources, allow_destroy: true, :reject_if => proc { |a| a['url'].blank? }

  has_many :participating_organizations, dependent: :destroy
  accepts_nested_attributes_for :participating_organizations, allow_destroy: true, :reject_if => proc { |a| a['organization_id'].blank? }


  # These used to be done inside the search block, now that FACETS are integrated, 
  # I had to move the code down here.
  def flagged 
    all_flags.map(&:name)
  end

  def commented
    comments.present? ? "Has Comments" : nil
  end








  def scope
    scope_array = []
    # RDM 2-26-2013 -- Updated for Scope model instead of SCOPES constant
    Scope.all.each do |scope|
      # Scope_hash is implemented in Scope#includes_project?
      if scope.includes_project? self
        scope_array << scope.symbol.to_sym
      end
    end

    return scope_array
  end

  def scope_names
    scope_array = []
    Scope.all.each do |scope|
      # Scope_hash is implemented in Scope#includes_project?
      if scope.includes_project? self
        scope_array << scope.name
      end
    end
    scope_array
  end
  #test_scope should be a symbol. 
  def contains_scope?(test_scope)
    scope_array = scope
    if scope_array.include?(test_scope)
      true
    else
      false
    end
  end




  def as_json(options={})
    super(
      only: [:id,:year, :title, :active, :is_commercial, :year_uncertain, :line_of_credit, :is_cofinanced, :debt_uncertain], 
      methods: [:usd_2009, :donor_name,
        :crs_sector_name, :flow_type_name, :oda_like_name, :status_name, 
        # :tied_name, 
        :recipient_condensed
    ],
      include: [
        {geopoliticals: {include: [{recipient: {only: [:name, :iso2, :iso3, :cow_code, :oecd_code]}}], only: [:percent]}},
        {transactions: {include: [{currency: {only: [:name, :iso3]}}], only: [:value, :usd_defl, :usd_current, :deflated_at, :deflator, :exchange_rate]}},
        {contacts: {only: [:name, :position], include: [organization: {only: [:name, :organization_type]}]}},
        {sources: {only: [:url, :date], include: [{source_type: {only: [:name]}}, {document_type: {only:[:name]}}]}},
        {participating_organizations: {only: [], include: [{origin: {only: [:name]}}, {organization: {only: [:name, :organization_type]}}, {role: {only: [:name]}}]}}
    ]) 
  end

  def all_flags
    [
      self.transactions.map(&:flags) + 
      self.geopoliticals.map(&:flags) +
      self.sources.map(&:flags) +
      self.contacts.map(&:flags) +
      self.participating_organizations.map(&:flags) +
      self.flags
    ].flatten
  end

  def flags
    Flag.where("flaggable_type not in(?) and flaggable_id= ?",ApplicationHelper::PROJECT_ACCESSORY_OBJECTS, id)
  end

  def set_verified_to_raw_if_null
    self.verified = Verified.find_by_name("Raw") if verified.blank?
  end

  def set_owner_to_aiddata_if_null
    self.owner = Organization.find_by_name("AidData") if owner.blank?
  end

end
