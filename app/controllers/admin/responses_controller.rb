# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to administering +Response+ objects
class Admin::ResponsesController < Admin::AdminController

  # The +show+, +edit+, +update+ and +responses+ actions need a +ContactForm+ object to act upon.
  before_filter :find_contact_form,       :only => [ :index, :upload_csv, :import_csv ]
  before_filter :set_paging,              :only => [ :index ]
  before_filter :set_sorting,             :only => [ :index ]
  
  skip_before_filter :find_node

  layout false

  # * GET /admin/contact_forms/:contact_form_id/responses
  # * GET /admin/contact_forms/:contact_form_id/responses.xml
  # * GET /admin/contact_forms/:contact_form_id/responses.csv
  # * GET /admin/contact_forms/:contact_form_id/responses.xls
  def index
    if params[:type] == 'xml'
      @responses = Response.all(:order => "#{@sort_field} #{@sort_direction}", :page => { :size => @page_limit, :current => @current_page }, :conditions => ["contact_form_id = ?", params[:contact_form_id].to_i])
    else
      @responses = @contact_form.responses
    end
    
    respond_to do |format|
      format.html #index.html.erb
      format.xml  #index.xml.builder
      format.csv  #index.csv.erb
      format.xls  #index.xls.erb
    end
  end

  # * PUT /admin/contact_forms/:contact_form_id/responses/:id.xml
  def update
    @response_field = ResponseField.find_by_response_id_and_contact_form_field_id(params[:response_id], params[:contact_form_field_id])
    @response_field = ResponseField.create(:response_id => params[:response_id], :contact_form_field_id => params[:contact_form_field_id]) if @response_field.nil?
    
    respond_to do |format|
      if @response_field.update_attributes(params[:response_field])
        format.xml  { head :ok }
      else
        format.xml  { render :xml => @response_field.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # * DELETE /admin/contact_forms/:contact_form_id/responses/:id
  # * DELETE /admin/contact_forms/:contact_form_id/responses/:id.json
  def destroy
    @response = Response.find(params[:id])
    
    respond_to do |format|
      @response.destroy
      format.html { redirect_to admin_responses_path }
      format.json { head :ok }
    end
  end
  
    # [ ] TODO: Form maken waarmee je file kunt uploaden
  def upload_csv
    # Determine the required order of files for the uploaded csv
    fields = []
    ContactFormField.all(:order => "position asc", :conditions => {:contact_form_id => @contact_form.id}).each do |field|
        fields << field.label
    end
    @csv_headers = fields.join(',');
    fields = nil
    # Headers op deze manier, daarop matchen
  end

  def import_csv
    csv_data = params[:response][:uploaded_data].read
    headers_ok = false
    headers = []
    FasterCSV.parse(csv_data) do |row|
      if(headers_ok)
        # [ ] TODO: kijken of dit goed gaat, row debuggen
        response_row = Response.create!(:contact_form => @contact_form, :ip => 'CSV-Import', :time => Time.now)
        response_row.save
        # Create response_field objects
        i = 0
        row.each do |field|
          ResponseField.create!(:response => response_row, :contact_form_field_id => headers[i], :value => field)
          i += 1
        end
      else
        field_labels = []
        fields = {}
        ContactFormField.all(:order => "position asc", :conditions => {:contact_form_id => @contact_form.id}).each do |field|
          fields[field.id] = field.label
          field_labels << field.label
        end
        andarr = (row & field_labels)
        if(andarr.length == field_labels.length)
          headers_ok = true
          row.each do |column|
            fields.each do |field|
              if column == field[1]
                headers << field[0]
              end
            end
          end
        else
          break
        end
      end
    end
    respond_to do |format|
      format.js do
        responds_to_parent do
          if headers_ok
            render :update do |page|
              page << "Ext.ux.showRightPanelMssg('#{escape_javascript(t('responses.done'))}')"
            end
          else
            render :update, :status => :unprocessable_entity do |page|
              page << "Ext.ux.showRightPanelMssg('#{escape_javascript(t('responses.failed'))}')"
            end
          end
        end
      end
    end
  end
  
  protected

  # Finds the +ContactForm+ object corresponding to the passed +id+ parameter.
  def find_contact_form
    @contact_form = ContactForm.find(params[:contact_form_id], :include => :contact_form_fields)
  end
  
  # Finds sorting parameters.
  def set_sorting
    if extjs_sorting?
      @sort_direction = (params[:dir] == 'ASC' ? 'ASC' : 'DESC')
      @sort_field = ActiveRecord::Base.connection.quote_column_name(params[:sort])
    else
      @sort_field = 'created_at'
    end
    @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /(id|created_at)/
  end
end
