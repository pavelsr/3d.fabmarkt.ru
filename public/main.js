$( document ).ready(function() {

	DrawSlider ('layer_height', 0.1, 0.1, 1, 0.3, 0);
	DrawSlider ('fill_density', 1, 1, 99, 10, 0);

	function DrawSlider (container_id, step, min, max, value, less_than_one) {
		var $id = $("#"+container_id);
		$id.find(".slider").slider({
			'step': step,
			'min': min,
			'max': max,
			'value': value,
			change: function ( event, ui ) {
				$id.find(".slider_val").empty();
				$id.find(".slider_val").append(ui.value).trigger("change");
			}
		});
		if (less_than_one == 1) {
			$id.find(".slider_val").append(getAccFromSlider(value));
		} else
			$id.find(".slider_val").append(value);
	}

	function getAccFromSlider(i) {
		return i/10;
	}

	$(".container").on("change", ".slider_val", function Serialize() {
	  if (typeof filename === 'undefined') {
	  	console.log("seems like old file was taken");
	  } else {
	  	var name_of_file = filename;
	  	console.log(filename);
	  }
	  var data = { params: [], file: name_of_file };
	  $(".ui-slider").each(function() {
	  		data.params.push({param: $(this).parent().parent().attr("id"), value: $(this).parent().parent().find(".slider_val").text() });
	  });
	  console.log(data.params);

	  $.post("/count", JSON.stringify(data)).done(function(response) {
	  	  var obj = jQuery.parseJSON(response);
	  	  $("#cost").empty();
	  	  $("#hours").empty();
	  	  $("#minutes").empty();
	  	  $("#seconds").empty();
	  	  
	  	  $("#cost").append(obj.cost);
	  	  $("#hours").append(obj.hours);
	  	  $("#minutes").append(obj.minutes);
	  	  $("#seconds").append(obj.seconds);
		  console.log(obj);
	  });
	});

});	

