//
//  GameScene.swift
//  ThrobsAndBobs
//
//  Created by AndyDent on 28/1/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var heartShader : SKShader?
    private var heartShaderNode : SKNode?
    private var discShaderNode : SKSpriteNode?
    private var makeDiscNext = true   // toggle for different kinds of nodes created each time
    private var beatRate: Float = 4.0
    private var heartPath = CGMutablePath()

    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        createHeartPathLocalCoords(scaledTo: view)
    }
    
    // produce a heartShape from an array of recorded points, scaled to fit current view
    // just to save awkwardness, calc offsets to centre these local coords every time we launch
    // once-off hit
    private func createHeartPathLocalCoords(scaledTo view: SKView)  {
        let xs = heartShape.map{$0.0}
        let ys = heartShape.map{$0.1}
        let xLeft = CGFloat(xs.min() ?? 0.0)
        let xRight = CGFloat(xs.max() ?? 0.0)
        let xOffset = xLeft + (xRight - xLeft)/2.0
        let yLeft = CGFloat(ys.min() ?? 0.0)
        let yRight = CGFloat(ys.max() ?? 0.0)
        let yOffset = yLeft + (yRight - yLeft)/2.0
        let scaleHeart = min(view.bounds.width, view.bounds.height) * 0.8  // may rescale later
        let heartShapeOutline = heartShape.map{CGPoint(x: ($0.0 - xOffset)*scaleHeart, y: ($0.1-yOffset)*scaleHeart)}
        heartPath.addLines(between: heartShapeOutline)
    }
    
    private func createHeartShader(width: CGFloat) {
        let ret = SKSpriteNode(color: .yellow, size: CGSize(width: width, height: width))  // use different color from heart so know when debugging that shader didn't draw anything
        if heartShader == nil {
            heartShader = SKShader(fromFile: "ThrobbingHeart2D")  // only one instance needed, which is optimal if many shaders active
        }
        ret.shader = heartShader
        heartShaderNode = ret
    }
    
    // alternately create different content on touch
    // ONE disc following a path or
    // MANY hearts, which slowly shrink and disappear
    func touchDown(atPoint pos : CGPoint) {
        let hsnWidth = (self.size.width + self.size.height) * 0.1
        if makeDiscNext {
            print("Disc shader beat rate \(beatRate)")
            if discShaderNode == nil {  // there is only ONE of these, gets moved & starts following path on every touch down
                let dotDia = hsnWidth/2.0  // aesthetic decision that dot should be half size of the heart
                let dsn = SKSpriteNode(color: .green, size: CGSize(width: dotDia, height: dotDia))
                dsn.shader = SKShader(fromFile: "ThrobbingDisc", uniforms: [SKUniform(name:"u_beat", float: beatRate)])
                dsn.position = pos
                self.addChild(dsn)
                discShaderNode = dsn  // just create one of these, will move it otherwise
            }
            else {
                discShaderNode?.position = pos
                discShaderNode?.shader?.uniforms[0] = SKUniform(name:"u_beat", float: beatRate)
            }
            discShaderNode?.run(SKAction.follow(heartPath, duration: 2.0))  // assumes heartPath in local coords of node running action
            makeDiscNext = false
            beatRate *= 2.0  // change the rate of the next disc to be shown
            if beatRate > 8.0 {
                beatRate = 0.5
            }
            return
        }
        if heartShaderNode == nil || !heartShaderNode!.position.close(to:pos, radius: hsnWidth+2.0) {
            // create new one first time or if tap far enough away, just debounces a create and drag
            createHeartShader(width: hsnWidth)
            self.addChild(heartShaderNode!)
            let nodeToRemove = heartShaderNode!
            heartShaderNode!.run(SKAction.scale(to: 0.1, duration: 10.0), completion: {[weak self, nodeToRemove]() -> Void  in
                if self?.heartShaderNode == nodeToRemove {
                    self?.heartShaderNode = nil  // forget it as removed after fade
                }
                nodeToRemove.removeFromParent()
            })
        }
        heartShaderNode!.position = pos
        makeDiscNext = true
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        heartShaderNode?.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // later maybe remove heartShaderNode if you wanted it to vanish after dragging
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

}

// from a hand recording, used in Touchgram's regression tests, all normalised coordinates
let heartShape: [(CGFloat, CGFloat)] = [
    (0.52183847427368169, 0.61776550722793799),
    (0.52183847427368169, 0.62128088507853763),
    (0.52495827674865725, 0.62303854713977225),
    (0.52495827674865725, 0.6283115870516065),
    (0.53119807243347172, 0.63358462696344076),
    (0.53431801795959477, 0.6371000048140405),
    (0.53743791580200195, 0.64413070678710938),
    (0.53743791580200195, 0.64764603090957862),
    (0.54055771827697752, 0.65116140876017825),
    (0.54367761611938481, 0.65291912454954337),
    (0.54679751396179199, 0.65643450240014301),
    (0.54991741180419917, 0.65819216446137763),
    (0.55303730964660647, 0.66346520437321188),
    (0.55615711212158203, 0.66698052849568112),
    (0.56239690780639651, 0.66873824428504625),
    (0.57175650596618655, 0.67225362213564588),
    (0.57487640380859373, 0.67401123046875),
    (0.57799634933471677, 0.67752660831934974),
    (0.58423609733581539, 0.67928432410871475),
    (0.58735594749450681, 0.67928432410871475),
    (0.61231503486633299, 0.68807268814301825),
    (0.61855473518371584, 0.68807268814301825),
    (0.62167468070983889, 0.68983040393238337),
    (0.6279144287109375, 0.68983040393238337),
    (0.6372740745544434, 0.68983040393238337),
    (0.65287346839904781, 0.68983040393238337),
    (0.67159276008605961, 0.68983040393238337),
    (0.6747126579284668, 0.68983040393238337),
    (0.6840723037719727, 0.68983040393238337),
    (0.68719215393066402, 0.68631502608178363),
    (0.6996716976165771, 0.682799648231184),
    (0.6996716976165771, 0.68104198616994938),
    (0.70903134346008301, 0.67401123046875),
    (0.71215124130249019, 0.67049590634628076),
    (0.71839098930358891, 0.66346520437321188),
    (0.7277506351470947, 0.64764603090957862),
    (0.73087048530578613, 0.63885772060340562),
    (0.73087048530578613, 0.6283115870516065),
    (0.73087048530578613, 0.62303854713977225),
    (0.73087048530578613, 0.619523223017303),
    (0.73087048530578613, 0.61249252104423413),
    (0.73087048530578613, 0.60370410328180013),
    (0.73087048530578613, 0.5914003076687665),
    (0.73087048530578613, 0.58964264560753188),
    (0.73087048530578613, 0.58788498354629737),
    (0.73087048530578613, 0.57558118793326363),
    (0.73087048530578613, 0.57206581008266399),
    (0.73087048530578613, 0.57030820174955987),
    (0.72463078498840328, 0.56151978398712588),
    (0.72463078498840328, 0.55624674407529162),
    (0.72151088714599609, 0.55273136622469188),
    (0.72151088714599609, 0.55097370416345726),
    (0.72151088714599609, 0.54394300219038838),
    (0.71527113914489748, 0.53163920657735475),
    (0.71215124130249019, 0.52988154451612013),
    (0.70591144561767583, 0.52109312675368613),
    (0.70279154777526853, 0.51582008684185188),
    (0.69343194961547849, 0.508789384868783),
    (0.69031205177307131, 0.50527400701818337),
    (0.68095240592956541, 0.49648558925574932),
    (0.68095240592956541, 0.49121260307204556),
    (0.67783255577087398, 0.48945488728268044),
    (0.6747126579284668, 0.48769727894957637),
    (0.6466337203979492, 0.471878105485943),
    (0.64351382255554201, 0.47012038969657788),
    (0.64039397239685059, 0.46836278136347381),
    (0.6279144287109375, 0.4630897414516395),
    (0.62167468070983889, 0.45957436360103981),
    (0.61855473518371584, 0.45781670153980525),
    (0.61231503486633299, 0.45605898575044013),
    (0.6091951370239258, 0.45430132368920556),
    (0.60607523918151851, 0.45430132368920556),
    (0.59671564102172847, 0.45078594583860587),
    (0.59047584533691411, 0.44902828377737125),
    (0.58111624717712407, 0.44551290592677156),
    (0.57799634933471677, 0.443755243865537),
    (0.56239690780639651, 0.43848223081776794),
    (0.55927700996398921, 0.43848223081776794),
    (0.55303730964660647, 0.43848223081776794),
    (0.54679751396179199, 0.43848223081776794),
    (0.54367761611938481, 0.43848223081776794),
    (0.54055771827697752, 0.43848223081776794),
    (0.53743791580200195, 0.43848223081776794),
    (0.53431801795959477, 0.43848223081776794),
    (0.53431801795959477, 0.44551290592677156),
    (0.53119807243347172, 0.44727059485207143),
    (0.52807817459106443, 0.44727059485207143),
    (0.52495827674865725, 0.44727059485207143),
    (0.51559867858886721, 0.45254360789984044),
    (0.50935888290405273, 0.45430132368920556),
    (0.4999992847442627, 0.45781670153980525),
    (0.48127994537353513, 0.4630897414516395),
    (0.48127994537353513, 0.46484740351287412),
    (0.47192034721374509, 0.46836278136347381),
    (0.46256070137023925, 0.471878105485943),
    (0.45008115768432616, 0.47363576754717762),
    (0.44696130752563479, 0.47539348333654269),
    (0.44072151184082031, 0.47715109166964681),
    (0.43760161399841307, 0.47890886118714238),
    (0.43448171615600584, 0.47890886118714238),
    (0.4251221179962158, 0.4806664695202465),
    (0.41888232231140138, 0.48418190109897669),
    (0.4064028263092041, 0.48769727894957637),
    (0.40016307830810549, 0.49121260307204556),
    (0.39080340862274171, 0.49472798092264525),
    (0.38456368446350098, 0.49648558925574932),
    (0.38144376277923586, 0.500000967106349),
    (0.36896426677703859, 0.508789384868783),
    (0.36584436893463135, 0.51054710065814812),
    (0.36272449493408204, 0.51230476271938274),
    (0.35336484909057619, 0.51933546469245162),
    (0.34712510108947753, 0.52812382872675501),
    (0.33776543140411375, 0.53866990855042363),
    (0.33464555740356444, 0.54218528640102337),
    (0.32528591156005859, 0.55097370416345726),
    (0.31904613971710205, 0.56151978398712588),
    (0.3096864938735962, 0.57558118793326363),
    (0.30344674587249754, 0.5914003076687665),
    (0.30032687187194823, 0.59667340130873125),
    (0.29720697402954099, 0.60194638749243512),
    (0.29408707618713381, 0.61249252104423413),
    (0.29408707618713381, 0.61776550722793799),
    (0.29408707618713381, 0.63358462696344076),
    (0.29408707618713381, 0.64237304472587475),
    (0.29720697402954099, 0.64940380042707413),
    (0.30032687187194823, 0.65643450240014301),
    (0.3096864938735962, 0.67049590634628076),
    (0.31280639171600344, 0.67401123046875),
    (0.31904613971710205, 0.67576894625811512),
    (0.32528591156005859, 0.682799648231184),
    (0.32840580940246583, 0.68631502608178363),
    (0.33776543140411375, 0.68983040393238337),
    (0.34712510108947753, 0.69510344384421763),
    (0.35336484909057619, 0.69686110590545225),
    (0.3596045970916748, 0.69861882169481737),
    (0.36272449493408204, 0.70037643002792138),
    (0.3752040147781372, 0.7021341458172865),
    (0.38144376277923586, 0.7021341458172865),
    (0.39080340862274171, 0.7021341458172865),
    (0.41576247215270995, 0.70389180787852113),
    (0.41888232231140138, 0.70389180787852113),
    (0.42200222015380862, 0.70389180787852113),
    (0.42824196815490723, 0.70389180787852113),
    (0.43760161399841307, 0.70389180787852113),
    (0.4532010555267334, 0.70037643002792138),
    (0.4532010555267334, 0.69861882169481737),
    (0.45632095336914064, 0.69686110590545225),
    (0.45944080352783201, 0.69686110590545225),
    (0.46568055152893068, 0.69334572805485251),
    (0.47192034721374509, 0.691588065993618),
    (0.47192034721374509, 0.68983040393238337),
    (0.47504019737243652, 0.68807268814301825),
    (0.48127994537353513, 0.68455736402054912),
    (0.48439984321594237, 0.682799648231184),
    (0.48751974105834961, 0.68104198616994938),
    (0.49063963890075685, 0.67928432410871475),
    (0.49375953674316408, 0.67576894625811512),
    (0.49687938690185546, 0.67401123046875),
    (0.4999992847442627, 0.67225362213564588),
    (0.4999992847442627, 0.66873824428504625),
    (0.50311918258666988, 0.66873824428504625),
    (0.50311918258666988, 0.6652228664344465),
    (0.50623908042907717, 0.66346520437321188),
    (0.50935888290405273, 0.66170754231197737),
    (0.50935888290405273, 0.65994982652261225),
    (0.50935888290405273, 0.65819216446137763),
    (0.50935888290405273, 0.65643450240014301),
    (0.51247878074645992, 0.65467678661077799),
    (0.51559867858886721, 0.65116140876017825),
    (0.51559867858886721, 0.64940380042707413),
    (0.51871857643127439, 0.64940380042707413),
    (0.51871857643127439, 0.64764603090957862),
    (0.51871857643127439, 0.6458884225764745),
    (0.51871857643127439, 0.64413070678710938),
    (0.52183847427368169, 0.64413070678710938),
    (0.52183847427368169, 0.64237304472587475)
]
