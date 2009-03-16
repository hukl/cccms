class OccurrencesController < ApplicationController
  # GET /occurrences
  # GET /occurrences.xml
  def index
    @occurrences = Occurrence.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @occurrences }
    end
  end

  # GET /occurrences/1
  # GET /occurrences/1.xml
  def show
    @occurrence = Occurrence.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @occurrence }
    end
  end

  # GET /occurrences/new
  # GET /occurrences/new.xml
  def new
    @occurrence = Occurrence.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @occurrence }
    end
  end

  # GET /occurrences/1/edit
  def edit
    @occurrence = Occurrence.find(params[:id])
  end

  # POST /occurrences
  # POST /occurrences.xml
  def create
    @occurrence = Occurrence.new(params[:occurrence])

    respond_to do |format|
      if @occurrence.save
        flash[:notice] = 'Occurrence was successfully created.'
        format.html { redirect_to(@occurrence) }
        format.xml  { render :xml => @occurrence, :status => :created, :location => @occurrence }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @occurrence.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /occurrences/1
  # PUT /occurrences/1.xml
  def update
    @occurrence = Occurrence.find(params[:id])

    respond_to do |format|
      if @occurrence.update_attributes(params[:occurrence])
        flash[:notice] = 'Occurrence was successfully updated.'
        format.html { redirect_to(@occurrence) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @occurrence.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /occurrences/1
  # DELETE /occurrences/1.xml
  def destroy
    @occurrence = Occurrence.find(params[:id])
    @occurrence.destroy

    respond_to do |format|
      format.html { redirect_to(occurrences_url) }
      format.xml  { head :ok }
    end
  end
end
