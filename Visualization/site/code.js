var dataFile = 'testOutput.json';
$(function(){ // on dom ready

var cy = cytoscape({
	container: document.getElementById('cy'),
	motionBlur: false,

	style: cytoscape.stylesheet()
		.selector('node')
			.css({'font-size': 10,
        'content': 'data(name)',
        'text-valign': 'center',
        'color': 'white',
        'text-outline-width': 2,
        'text-outline-color': '#888',
        'min-zoomed-font-size': 8,
        'width': 'mapData(score, 0, 1, 20, 50)',
        'height': 'mapData(score, 0, 1, 20, 50)'})
		.selector('edge:selected')
      		.css({'font-size': 10,
        'content': 'data(weight)',
        'text-valign': 'center',
        'color': 'white',
        'text-outline-width': 0.5,
        'text-outline-color': '#888',
      }),
	elements: Jsondata

         });


// var layout = cy.makeLayout({
//   name: 'springy',

//   animate: true, // whether to show the layout as it's running
//   maxSimulationTime: 4000, // max length in ms to run the layout
//   ungrabifyWhileSimulating: false, // so you can't drag nodes during layout
//   fit: true, // whether to fit the viewport to the graph
//   padding: 30, // padding on fit
//   boundingBox: undefined, // constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }
//   random: false, // whether to use random initial positions
//   infinite: true, // overrides all other options for a forces-all-the-time mode
//   ready: undefined, // callback on layoutready
//   stop: undefined, // callback on layoutstop

//   // springy forces
//   stiffness: 400,
//   repulsion: 400,
//   damping: 0.5
// });


var layout = cy.makeLayout({   name: 'cola',

  animate: true, // whether to show the layout as it's running
  refresh: 15, // number of ticks per frame; higher is faster but more jerky
  maxSimulationTime: 2000, // max length in ms to run the layout
  ungrabifyWhileSimulating: false, // so you can't drag nodes during layout
  fit: true, // on every layout reposition of nodes, fit the viewport
  padding: 30, // padding around the simulation
  boundingBox: undefined, // constrain layout bounds; { x1, y1, x2, y2 } or { x1, y1, w, h }

  // layout event callbacks
  ready: function(){}, // on layoutready
  stop: function(){}, // on layoutstop

  // positioning options
  randomize: false, // use random node positions at beginning of layout
  avoidOverlap: true, // if true, prevents overlap of node bounding boxes
  handleDisconnected: true, // if true, avoids disconnected components from overlapping
  nodeSpacing: function( node ){ return 10; }, // extra spacing around nodes
  flow: undefined, // use DAG/tree flow layout if specified, e.g. { axis: 'y', minSeparation: 30 }
  alignment: undefined, // relative alignment constraints on nodes, e.g. function( node ){ return { x: 0, y: 1 } }

  // different methods of specifying edge length
  // each can be a constant numerical value or a function like `function( edge ){ return 2; }`
  edgeLength: undefined, // sets edge length directly in simulation
  edgeSymDiffLength: undefined, // symmetric diff edge length in simulation
  edgeJaccardLength: undefined, // jaccard edge length in simulation

  // iterations of cola algorithm; uses default values on undefined
  unconstrIter: undefined, // unconstrained initial layout iterations
  userConstIter: undefined, // initial layout iterations with user-specified constraints
  allConstIter: undefined, // initial layout iterations with all constraints including non-overlap

  // infinite layout options
  infinite: false // overrides all other options for a forces-all-the-time mode
	});



layout.run();

});

var Jsondata;
$.getJSON(dataFile, {}, function(data) {
	Jsondata = data.elements;
});
