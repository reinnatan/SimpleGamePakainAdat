extends Node2D

var items
var random_answer
var base_url
var http
var counter = 0
var false_answer = 0
var true_answer = 0

func _ready() -> void:
	_init_component()

func _init_component():
	DisplayServer.window_set_size(Vector2i(1280, 720))
	DisplayServer.window_set_position(Vector2i(100, 100))
	$TextureRect.custom_minimum_size = Vector2(300, 300)
	http = HTTPRequest.new()
	add_child(http)
	
	#add listener answer to each button
	$Button.pressed.connect(_answer_button_1.bind("button1"))	
	$Button2.pressed.connect(_answer_button_2.bind("button2"))
	$Button3.pressed.connect(_answer_button_3.bind("button3"))	
	$Button4.pressed.connect(_answer_button_4.bind("button4"))
	
	#init the data
	http.request_completed.connect(_on_request_completed_init_data)
	var err = http.request("https://raw.githubusercontent.com/reinnatan/PakaianAdat/refs/heads/master/listing.json")
	print("Terjadi error load data "+str(err))
	

func _reload_image_question(index):
	#load the first image
	http.request_completed.connect(_on_load_image_init)
	var temp_image = items[index]['image_url']
	var err = http.request(base_url+temp_image)
	print("Terjadi error load image "+str(err))


func _on_load_image_init(result, response_code, headers, body):
	var image = Image.new()
	var err = image.load_jpg_from_buffer(body)
	if err != OK:
		err = image.load_png_from_buffer(body)
	if err != OK:
		print("Image decode failed")
		return
	var texture = ImageTexture.create_from_image(image)
	$TextureRect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	$TextureRect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	$TextureRect.texture = texture
	$TextureRect.position = Vector2(350,60)
	#print("Selesai load image")

func _answer_button_1(action):
	var answer = $Button.text
	_check_asnwer(answer, items[counter]['province'])

func _answer_button_2(action):
	var answer = $Button2.text
	_check_asnwer(answer, items[counter]['province'])
	
func _answer_button_3(action):
	var answer = $Button3.text
	_check_asnwer(answer, items[counter]['province'])
	
func _answer_button_4(action):
	var answer = $Button4.text
	_check_asnwer(answer, items[counter]['province'])
	
func _check_asnwer(user_answer, correct_answer):
	if(user_answer == correct_answer):
		print("Jawaban Anda Benar")
		true_answer +=1
	else:
		print("Jawaban Anda Salah")
		false_answer +=1
		
	counter +=1
	if counter < items.size()-1:
		_reload_image_question(counter)
		_random_answer_question(counter)
	else :
		$AcceptDialog.size = Vector2(400, 300)
		$AcceptDialog.add_theme_font_size_override("font_size", 34)
		$AcceptDialog.title = "Anda sudah memenangkan game ini"
		$AcceptDialog.dialog_text = "Jawaban Benar "+ str(true_answer) +"\n"+"Jawaban Salah "+ str(false_answer)+"\n"+"Total Jawaban "+str(items.size()-1)
		$AcceptDialog.popup_centered()
		#print("Anda Sudah memenagkan game ini")
	
func _random_answer_question(index):
	var current = items[index]['province']
	var temp_filter = [current]
	var filter = items.filter(func(item):
		return not temp_filter.has(item)
	)
	
	var random_number = [1,2,3,4]
	var selected_random = random_number.pick_random()
	if selected_random == 1:
		$Button.text = current
		temp_filter.append($Button.text)
	else :
		$Button.text = filter.pick_random()['province']
		temp_filter.append($Button.text)
	
	if selected_random == 2:
		$Button2.text = current
		temp_filter.append($Button2.text)
	else:
		filter = items.filter(func(item):
			return not temp_filter.has(item)
		)
		$Button2.text =  filter.pick_random()['province']
		temp_filter.append($Button2.text)
	
	if selected_random == 3:
		$Button3.text = current
		temp_filter.append($Button3.text)
	else:
		filter = items.filter(func(item):
			return not temp_filter.has(item)
		)
		$Button3.text = filter.pick_random()['province']
		temp_filter.append($Button3.text)
	
	if selected_random == 4:
		$Button4.text = current
		temp_filter.append($Button4.text)
	else:
		filter = items.filter(func(item):
			return not temp_filter.has(item)
		)
		$Button4.text =  filter.pick_random()['province']		
	
	

func _on_request_completed_init_data(result, response_code, headers, body):
	var json = await JSON.parse_string(body.get_string_from_utf8())
	if(json!=null):
		if(json.has('base_url')):
			base_url = json['base_url']
			items = json['items']
			items.shuffle()
			_reload_image_question(counter)
			_random_answer_question(counter)
	
	
