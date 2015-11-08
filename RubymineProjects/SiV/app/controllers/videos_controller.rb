require 'nokogiri'
require 'open-uri'

require 'viddl-rb'
class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]


  def newpage
  end


  # GET /videos
  # GET /videos.json
  def index

  #  Localvdo.all.each do |llvideo|
  #    ping llvideo.url
  #    ping "http://www.google.com"
  #  end
   # ping "http://www.google.com"
    puts "Inside index..............."
    if current_user
      #token = current_user.oauth_token

      Koala.config.api_version = "v2.0"

      @graph = Koala::Facebook::API.new(current_user.oauth_token)
      #  profile = @graph.get_object("me")
      friends = @graph.get_connections("me", "friends")
      puts "frilit shld be here"
      puts friends
      @frilist = Array.new

      friends.each do |hash|
        @frilist.push(hash['id'])
        puts hash['id']

      end
    end
    @same_network = is_same_network(session[:user_id])
    @Nvideos = Video.all
    # @Nvideos = @videolist
    @videos = @Nvideos.order(:created_at).reverse
    # sorted = @records.sort_by &:created_at
    @locals = Localvdo.all


    @local_videos = @locals.order(:created_at).reverse


    # @friends = friendlistreturn
  end


  def ping(host)
    begin
      url=URI.parse(host)
      start_time = Time.now
      response=Net::HTTP.get(url)
      end_time = Time.now - start_time
      if response==""
        return false
      else
        puts "response time ...................: #{end_time}"
        return true
      end
    rescue Errno::ECONNREFUSED
      return false
    end
  end


  # GET /videos/1
  # GET /videos/1.json
  def show
    @sessionId = session[:user_id]
    @same_network = is_same_network(session[:user_id])
    @id = @video.user_id
  end

  # GET /videos/1
  def stream
    @same_network = is_same_network(session[:user_id])
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
    @localvdo_for_given_user = Localvdo.where(user_id: session[:user_id])
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render action: 'show', status: :created, location: @video }
      else
        format.html { render action: 'new' }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    puts "call update Video info"
    puts video_params

    respond_to do |format|
      if @video.update(video_params)
        if @video.local_link.length > 0
          @video.inLocal = true
        end
        @video.save!
        @user = User.find(session[:user_id])
        format.html { redirect_to @user, notice: 'Video was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @user = User.find(session[:user_id])
    @video.destroy
    respond_to do |format|
      format.html { redirect_to @user }
      format.json { head :no_content }
    end
  end

  def timelinevdo
    puts "Time line video................."
    vdo_list = []
    user_id = session[:user_id]
    user_obj = User.find(user_id)
    url = 'https://graph.facebook.com/v2.0/' + user_obj.uid + '?fields=posts&access_token=' + user_obj.oauth_token
    raw_data = open(url).read
    json_data = JSON.parse(raw_data)

    json_data['posts']['data'].each do |obj|

      if obj['type'] == "swf" || obj['type']== "video" || obj['type']== "link"

        if obj['link'].include? "www.youtube.com"
          puts "Youtube link"

          vdo_list.append(youtube_embed(obj['link'], obj['id']))
puts obj['link']
        elsif not obj['source'].nil?
          if obj['source'].include? "www.youtube.com"
            puts "Youtube link"
            puts obj['link']
            vdo_list.append(youtube_embed(obj['source'], obj['id']))
          elsif obj['source'].include? "vimeo.com"
            puts "vimeo link"
            vdo_list.append(vimeo_embed(obj['source'], obj['id']))
          else
            puts "User uploaded video link"
            vdo_list.append(facebook_embed(obj['source'], obj['id']))
          end
        end

      end

    end


    @contents = vdo_list
  end

  def delete

    listOne= Localvdo.pluck(:post_id)
    listTwo = Array.new
    #Detection of deleted videos
    json_data['posts']['data'].each do |obj|
      if obj['type'] == "swf" || obj['type']== "video"|| obj['type'] == "link"

        if obj['link'].include? "www.youtube.com"
          listTwo.append(obj['id'])
          puts obj['id']
        elsif not obj['source'].nil?
          if obj['source'].include? "www.youtube.com"
            listTwo.append(obj['id'])
            puts obj['id']
          end
        end
      end
    end
    deleteVideo = listOne - listTwo
    puts "Deleted Videoooooooooooooooo"
    puts deleteVideo
    if deleteVideo
      deleteVideo.each do |obj|
        name_of_video = Localvdo.find_by_post_id(obj).video_file_name

        puts "Destroying Video from dropbox"
        system ("bash ~/Dropbox-Uploader/dropbox_uploader.sh delete /Public/'#{name_of_video}'")
        puts "Destroying video from Active record"
        dVideo = Localvdo.find_by_post_id(obj).destroy
        puts dVideo
        #  @client = Dropbox::API::Client.new(:token  => "pa8g47kzltdus4a1", :secret => "fwno07n27l1f6ii")
        #  client.destroy "#{name_of_video}"
      end
    end
  end
  #YouTube Detection
  def youtube_embed(youtube_url, post_id)
    puts "Youtube url............................"

you_url = youtube_url
    puts you_url
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      ## Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end

    url = "https://www.youtube.com/watch?v=#{youtube_id}"

    downloadvdo(url,youtube_id,post_id,you_url)
    #downloadvdo(youtube_url, youtube_id, post_id)
    %Q{<iframe title="YouTube video player" width="640" height="390" src="http://www.youtube.com/embed/#{ youtube_id}" frameborder="0" allowfullscreen controls></iframe>}
  end


  #Vimeo Detection
  def vimeo_embed(vimeo_url, post_id)

    vimeo_url["autoplay=1"]= "autoplay=0"
    #  puts vimeo_url
    %Q{<iframe width="400" height="300" name="autoplay" value="0" src="#{vimeo_url}" frameborder="0" allowfullscreen controls></iframe>}
  end

  def facebook_embed(facebook_url, post_id)
    %Q{<video width="400" height="300" name="autoplay" value="false" src="#{facebook_url}" frameborder="0" allowfullscreen controls></video>}
  end


  def downloadvdo(url, youtube_id, fbpost_id,you_url)
    #video_id_list = Localvdo.pluck(:post_id)
    #if fbpost_id
    uid = session[:user_id]
    name = ViddlRb.get_names(url)

    video_name = name.first.split.join('_')
    puts video_name
    #if Localvdo.exists?(:url => url)
    if Localvdo.exists?(:user_id => uid, :video_file_name => video_name)
      puts "Video already available in the local server..............."
    else
      puts "Downloading vdo----------------------------check name"
      #  puts video_name
      puts name.first
      file = name.first
      system ("viddl-rb #{url} --save-dir ~/SiV/public/Video")
      #remove name spaces with underscore
      system ("mv ~/RubymineProjects/SiV/public/Video/'#{file}' ~/SiV/public/Video/'#{video_name}'")
      #system ("mv ~/RubymineProjects/SiV/public/Video/'#{file}' ~/RubymineProjects/SiV/public/Video/'#{video_name}'")
#      query = "INSERT INTO download_vdo VALUES ('#{video_name}','#{url}','#{uid}',CURRENT_DATE);"
      #    ActiveRecord::Base.connection.execute(query);


      #Creating local video for local list
      @localvdo = Localvdo.new
      @localvdo.user_id = uid
      #@localvdo.post_id = fbpost_id
      @localvdo.url = "http://www.youtube.com/embed/#{ youtube_id}"
      @localvdo.video_file_size = file.size
      @localvdo. video_file_name = video_name
      @localvdo.originalURL= you_url
      @localvdo.save


      puts "Finish Saving Local vdo #{video_name}"
      if File.exist?("~/RubymineProjects/SiV/public/Video/'#{video_name}'")
        puts "Sorry No File exist"
      else
        system ("bash ~/Dropbox-Uploader/dropbox_uploader.sh upload ~/SiV/public/Video/'#{video_name}' Public")
        puts "Finish Uploading"
        #delete the file after uploading
        system ("rm ~/SiV/public/Video/'#{video_name}'")
      end


    end


  end


  def fetch
    puts "Fetching Facebook shared videos (UGC upload)....................."

    user_id = session[:user_id]
    user_obj = User.find(user_id)
    options = {:access_token => user_obj.oauth_token}
    query = 'SELECT owner, vid, title, thumbnail_link, embed_html FROM video WHERE owner=me()'

    begin
      @parsed_json = Fql.execute(query, options)
      puts @parsed_json

      @parsed_json.each do |obj|
        if Video.where(:uid => user_obj.uid, :facebook_vid => obj['vid'].to_s).blank?
          #puts "current obj['vid'] = " + obj['vid'].to_s

          vdo = Video.new()
          if obj['title'].length == 0
            vdo.name = "untitled"
          else
            vdo.name = obj['title']
          end
          vdo.thumbnail_link = obj['thumbnail_link']
          vdo.link = obj['embed_html']
          vdo.local_link = ""
          vdo.facebook_vid = obj['vid']
          vdo.uid = user_obj.uid
          vdo.user_id = user_id
          vdo.inLocal = false
          vdo.save!
        end
      end
      redirect_to user_obj
    rescue Exception
      redirect_to "/auth/facebook"
    end
  end



  def fetch_new
    user_id = session[:user_id]
    # puts user_id
    user_obj = User.find(user_id)
    url = 'https://graph.facebook.com/v2.0/' + user_obj.uid + '?fields=posts&access_token=' + user_obj.oauth_token
    # puts url
    raw_data = open(url).read
    #  puts raw_data
    json_data = JSON.parse(raw_data)

    json_data['posts']['data'].each do |obj|
      if obj['type'] == "video" && Video.pluck(:facebook_vid) != obj['id']
        vdo = Video.new()
        # if obj['title'].length == 0
        vdo.name = "untitled"
        # else
        #  vdo.name = obj['title']
        # end
        vdo.thumbnail_link = obj['picture']



        vdo.local_link = ""
        vdo.facebook_vid = obj['id']
        vdo.uid = user_obj.uid
        vdo.user_id = user_id
        if obj['status_type'] == "added_video"
          vdo.inLocal = true
          vdo.link = obj['id'].split("_",2)[1]
        else
          vdo.inLocal = false
        end

        vdo.save!
        # <iframe src= <%video.link%> width="500" height="300" frameborder="0"></iframe>

      end

    end
    redirect_to user_obj
  rescue Exception
    redirect_to "/auth/facebook"
  end

  def is_same_network(id)
    result = true
    if current_user
      loginUser_city = User.find(id).city
      puts loginUser_city
      # videoOwner_id = @video.user_id
      # videoOwner_city = User.find(videoOwner_id).city
      # puts videoOwner_city
      #       videoOwner_id = @video.user_id
      #       videoOwner_city = User.find(videoOwner_id).city
      if loginUser_city == "Évry"
        result = true
      else
        result= false
      end
      result
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_video
    @video = Video.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def video_params
    params.require(:video).permit(:name, :uid, :link, :inLocal, :local_link)
  end

end
