class Seo::SearchTermsController < ApplicationController
  before_filter :login_required, :except=>[:index]
  permit 'admin', :permission_denied_message => 'Permission Denied.', :except=>[:index]
  ssl_required :show, :new, :edit, :create, :update, :destroy, :query_update, :query
  ssl_allowed :index

  layout 'admin'

  def setup_includes
    super
    init_includes :admin
  end

  # GET /seo_search_terms
  # GET /seo_search_terms.xml
  def index

    if params[:sort_column].nil?
      @seo_search_terms = Seo::SearchTerm.ordered.with_queries
    else
      params[:sort_order] = 'asc' if (params[:sort_order].nil? or (params[:sort_order]!='asc' and params[:sort_order]!='desc'))
      @seo_search_terms = Seo::SearchTerm.ordered("#{params[:sort_column]} #{params[:sort_order].upcase}").with_queries
      if params[:sort_order]!='desc'
        @sort_order = 'desc'
      else
        @sort_order = 'asc'
      end
    end

    respond_to do |format|
      format.html do
        return if not login_required
        if permit?('admin')
          render # index.html.erb
        else
          redirect_to '/'; return
        end
      end
      #format.xml  { render :xml => @seo_search_terms }
      format.atom do
        if rss_authentication
          @first_seo_search_term = Seo::SearchTerm.ordered("updated_at DESC").first
          if stale?(:last_modified => @first_seo_search_term.updated_at.utc, :etag => @first_seo_search_term)
            @rss = true
            render :layout=>false # index.atom.builder
          end
        end
      end
    end
  end

  # GET /seo_search_terms/1
  # GET /seo_search_terms/1.xml
  def show
    @seo_search_term = Seo::SearchTerm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @seo_search_term }
    end
  end

  # GET /seo_search_terms/new
  # GET /seo_search_terms/new.xml
  def new
    @seo_search_term = Seo::SearchTerm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @seo_search_term }
    end
  end

  # GET /seo_search_terms/1/edit
  def edit
    @seo_search_term = Seo::SearchTerm.find(params[:id])
  end

  # POST /seo_search_terms
  # POST /seo_search_terms.xml
  def create
    params[:seo_search_term][:term] = params[:seo_search_term][:term].strip unless params[:seo_search_term][:term].nil?
    @seo_search_term = Seo::SearchTerm.find_by_term(params[:seo_search_term][:term])
    @seo_search_term = Seo::SearchTerm.new(params[:seo_search_term]) if @seo_search_term.nil?

    respond_to do |format|
      if @seo_search_term.save
        flash[:notice] = 'Seo::SearchTerm was successfully created.'
        format.html { redirect_to seo_search_terms_path }
        format.xml  { render :xml => @seo_search_term, :status => :created, :location => @seo_search_term }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @seo_search_term.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /seo_search_terms/1
  # PUT /seo_search_terms/1.xml
  def update
    @seo_search_term = Seo::SearchTerm.find(params[:id])

    respond_to do |format|
      if @seo_search_term.update_attributes(params[:seo_search_term])
        flash[:notice] = 'Seo::SearchTerm was successfully updated.'
        format.html { redirect_to seo_search_terms_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @seo_search_term.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /seo_search_terms/1
  # DELETE /seo_search_terms/1.xml
  def destroy
    @seo_search_term = Seo::SearchTerm.find(params[:id])
    @seo_search_term.destroy

    flash[:notice] = 'Seo::SearchTerm was successfully destroyed.'
    respond_to do |format|
      format.html { redirect_to(seo_search_terms_url) }
      format.xml  { head :ok }
    end
  end

  def query
    @seo_search_term = Seo::SearchTerm.find(params[:id])
    if not @seo_search_term.nil?
      Workling.return.set("seo_#{@seo_search_term.id}_progress", 0.0)
      SeoWorker.async_run_seo_queries(:search_term_id => @seo_search_term.id)
    end
    respond_to do |format|
      format.js { render }
      format.html { redirect_to(seo_search_terms_url) }
      format.xml  { head :ok }
    end
  end

  def query_update
    @seo_search_term = Seo::SearchTerm.find(params[:id])
    if not @seo_search_term.nil?
      cache = Workling.return.get("seo_#{@seo_search_term.id}_progress")
      @progress = cache if not cache.nil?
    end
    respond_to do |format|
      format.js { render }
    end
  end

end
