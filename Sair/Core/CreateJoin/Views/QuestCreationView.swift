//
//  QuestCreationView.swift
//  Sair
//
//  Created by Shravan Rajput on 11/03/25.
//
// Core/CreateJoin/Views/QuestCreationView.swift
import SwiftUI
import MapplsMap
import MapplsAPIKit

struct QuestCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = QuestCreationViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundCream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Step indicator
                    StepIndicator(currentStep: viewModel.currentStep, steps: ["Details", "Start", "End", "Route", "Finish"])
                        .padding(.top)
                    
                    // Content based on current step
                    ScrollView {
                        VStack(spacing: 20) {
                            // Different content for each step
                            Group {
                                switch viewModel.currentStep {
                                case 0:
                                    QuestDetailsStep(viewModel: viewModel)
                                case 1:
                                    QuestStartLocationStep(viewModel: viewModel)
                                case 2:
                                    QuestEndLocationStep(viewModel: viewModel)
                                case 3:
                                    QuestRoutePreviewStep(viewModel: viewModel)
                                case 4:
                                    QuestFinalDetailsStep(viewModel: viewModel)
                                default:
                                    EmptyView()
                                }
                            }
                            .padding(.horizontal)
                            
                            if viewModel.errorMessage != nil {
                                Text(viewModel.errorMessage!)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.horizontal)
                            }
                            
                            Spacer(minLength: 80) // Space for buttons
                        }
                        .padding(.top)
                    }
                    
                    // Navigation buttons
                    VStack {
                        if viewModel.currentStep == 4 {
                            // Create button on final step
                            Button(action: {
                                viewModel.saveQuest { success, error in
                                    if success {
                                        presentationMode.wrappedValue.dismiss()
                                    } else if let error = error {
                                        viewModel.errorMessage = error
                                    }
                                }
                            }) {
                                if viewModel.isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Create Quest")
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(viewModel.isSaving)
                        } else {
                            // Next/Back buttons for other steps
                            HStack {
                                if viewModel.currentStep > 0 {
                                    Button(action: {
                                        withAnimation {
                                            viewModel.currentStep -= 1
                                        }
                                    }) {
                                        Text("Back")
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .foregroundColor(.primary)
                                            .cornerRadius(10)
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        viewModel.currentStep += 1
                                    }
                                }) {
                                    Text("Next")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(viewModel.canProceedFromStep(viewModel.currentStep) ? Color.primaryGreen : Color.gray.opacity(0.5))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(!viewModel.canProceedFromStep(viewModel.currentStep))
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, y: -5)
                }
            }
            .navigationTitle("Create a Quest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primaryGreen)
                    }
                }
            }
        }
    }
}

// Step Indicator Component
struct StepIndicator: View {
    var currentStep: Int
    var steps: [String]
    
    init(currentStep: Int, steps: [String]) {
        self.currentStep = currentStep
        self.steps = steps
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress dots
            HStack(spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack {
                        // Line before
                        if index > 0 {
                            Rectangle()
                                .fill(index <= currentStep ? Color.primaryGreen : Color.gray.opacity(0.3))
                                .frame(height: 3)
                        } else {
                            Spacer()
                                .frame(height: 3)
                        }
                        
                        // Dot
                        Circle()
                            .fill(index < currentStep ? Color.primaryGreen : (index == currentStep ? Color.primaryGreen : Color.gray.opacity(0.3)))
                            .frame(width: 16, height: 16)
                        
                        // Line after
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(index < currentStep ? Color.primaryGreen : Color.gray.opacity(0.3))
                                .frame(height: 3)
                        } else {
                            Spacer()
                                .frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            
            // Step labels
            HStack(spacing: 0) {
                ForEach(0..<steps.count, id: \.self) { index in
                    Text(steps[index])
                        .font(.caption)
                        .foregroundColor(index <= currentStep ? .primaryGreen : .gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom)
    }
}

// Step 1: Quest Details
struct QuestDetailsStep: View {
    @ObservedObject var viewModel: QuestCreationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Quest Details")
                .font(.headline)
                .foregroundColor(.primaryGreen)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                TextField("Enter quest title", text: $viewModel.title)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                Picker("Category", selection: $viewModel.category) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
            }
        }
    }
}

// Step 2: Start Location
struct QuestStartLocationStep: View {
    @ObservedObject var viewModel: QuestCreationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Set Start Location")
                .font(.headline)
                .foregroundColor(.primaryGreen)
            
            // Search field
            VStack(alignment: .leading, spacing: 8) {
                Text("Search for start location")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                ZStack {
                    TextField("Search places", text: $viewModel.startSearchText, onCommit: {
                        viewModel.searchFocus = .start
                        viewModel.searchLocations(query: viewModel.startSearchText)
                    })
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    .onChange(of: viewModel.startSearchText) { newValue in
                        if newValue.count > 2 {
                            viewModel.searchFocus = .start
                            viewModel.searchLocations(query: newValue)
                        }
                    }
                    
                    if viewModel.isSearching {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding(.trailing)
                        }
                    }
                }
                
                // Search results
                if !viewModel.searchResults.isEmpty && viewModel.searchFocus == .start {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.searchResults, id: \.mapplsPin) { suggestion in
                                Button(action: {
                                    viewModel.selectLocation(suggestion)
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suggestion.placeName ?? "Unnamed Place")
                                            .foregroundColor(.primary)
                                        
                                        Text(suggestion.placeAddress ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                        
                                        Divider()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .frame(maxHeight: 200)
                }
            }
            
            // Selected location
            if let location = viewModel.startLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Start Location")
                        .foregroundColor(.primaryGreen)
                        .font(.subheadline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.headline)
                            
                            Text("Lat: \(location.latitude), Lng: \(location.longitude)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.startLocation = nil
                            viewModel.startSearchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }
}

// Step 3: End Location
struct QuestEndLocationStep: View {
    @ObservedObject var viewModel: QuestCreationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Set End Location")
                .font(.headline)
                .foregroundColor(.primaryGreen)
            
            // Search field
            VStack(alignment: .leading, spacing: 8) {
                Text("Search for end location")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                ZStack {
                    TextField("Search places", text: $viewModel.endSearchText, onCommit: {
                        viewModel.searchFocus = .end
                        viewModel.searchLocations(query: viewModel.endSearchText)
                    })
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    .onChange(of: viewModel.endSearchText) { newValue in
                        if newValue.count > 2 {
                            viewModel.searchFocus = .end
                            viewModel.searchLocations(query: newValue)
                        }
                    }
                    
                    if viewModel.isSearching {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding(.trailing)
                        }
                    }
                }
                
                // Search results
                if !viewModel.searchResults.isEmpty && viewModel.searchFocus == .end {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.searchResults, id: \.mapplsPin) { suggestion in
                                Button(action: {
                                    viewModel.selectLocation(suggestion)
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suggestion.placeName ?? "Unnamed Place")
                                            .foregroundColor(.primary)
                                        
                                        Text(suggestion.placeAddress ?? "")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                        
                                        Divider()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    .frame(maxHeight: 200)
                }
            }
            
            // Selected location
            if let location = viewModel.endLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected End Location")
                        .foregroundColor(.primaryGreen)
                        .font(.subheadline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.headline)
                            
                            Text("Lat: \(location.latitude), Lng: \(location.longitude)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.endLocation = nil
                            viewModel.endSearchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
    }
}

// Step 4: Route Preview
struct QuestRoutePreviewStep: View {
    @ObservedObject var viewModel: QuestCreationViewModel
    @State private var mapView: MapplsMapView?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Route Preview")
                .font(.headline)
                .foregroundColor(.primaryGreen)
            
            // Map with route
            ZStack {
                RouteMapViewContainer(
                    mapView: $mapView,
                    startLocation: viewModel.startLocation,
                    endLocation: viewModel.endLocation,
                    intermediateLocations: viewModel.intermediateLocations,
                    routePolyline: viewModel.routePolyline
                )
                .frame(height: 250)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                if viewModel.isCalculatingRoute {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
            
            // Route details
            if viewModel.isRouteCalculated {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Route Details")
                        .font(.subheadline)
                        .foregroundColor(.primaryGreen)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("Distance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(formatDistance(viewModel.routeDistance))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        
                        VStack {
                            Text("Duration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(formatDuration(viewModel.routeTime))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    
                    // Recalculate route button
                    Button(action: {
                        viewModel.calculateRoute()
                    }) {
                        Label("Recalculate Route", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundColor(.primaryGreen)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.primaryGreen.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            } else if !viewModel.isCalculatingRoute {
                // Calculate route button if not yet calculated
                Button(action: {
                    viewModel.calculateRoute()
                }) {
                    Label("Calculate Route", systemImage: "arrow.triangle.swap")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryGreen)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // Helper to format distance
    func formatDistance(_ meters: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        
        let measurement: Measurement<UnitLength>
        
        if meters >= 1000 {
            measurement = Measurement(value: meters / 1000, unit: UnitLength.kilometers)
        } else {
            measurement = Measurement(value: meters, unit: UnitLength.meters)
        }
        
        return formatter.string(from: measurement)
    }
    
    // Helper to format duration
    func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(remainingMinutes) min"
            }
        }
    }
}

// Step 5: Final Quest Details
struct QuestFinalDetailsStep: View {
    @ObservedObject var viewModel: QuestCreationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Final Details")
                .font(.headline)
                .foregroundColor(.primaryGreen)
            
            // Difficulty slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Difficulty Level")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                HStack {
                    Text("Easy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { Double(viewModel.difficulty) },
                        set: { viewModel.difficulty = Int($0) }
                    ), in: 1...5, step: 1)
                    .accentColor(.primaryGreen)
                    
                    Text("Hard")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(level <= viewModel.difficulty ? difficultyColor(level) : Color.gray.opacity(0.3))
                            .overlay(
                                Text("\(level)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Points value
            VStack(alignment: .leading, spacing: 8) {
                Text("Points Value")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                HStack {
                    Slider(value: Binding(
                        get: { Double(viewModel.pointsValue) },
                        set: { viewModel.pointsValue = Int($0) }
                    ), in: 50...500, step: 50)
                    .accentColor(.primaryGreen)
                    
                    Text("\(viewModel.pointsValue)")
                        .font(.headline)
                        .foregroundColor(.primaryGreen)
                        .frame(width: 60)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Public/Private toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Visibility")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                Toggle(isOn: $viewModel.isPublic) {
                    HStack {
                        Image(systemName: viewModel.isPublic ? "globe" : "lock")
                            .foregroundColor(viewModel.isPublic ? .primaryGreen : .gray)
                        
                        Text(viewModel.isPublic ? "Public - visible to all users" : "Private - only visible to you")
                            .font(.subheadline)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .primaryGreen))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Quest Summary")
                    .foregroundColor(.primaryGreen)
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 12) {
                    SummaryRow(label: "Title", value: viewModel.title)
                    SummaryRow(label: "Category", value: viewModel.category)
                    SummaryRow(label: "From", value: viewModel.startLocation?.name ?? "")
                    SummaryRow(label: "To", value: viewModel.endLocation?.name ?? "")
                    SummaryRow(label: "Distance", value: formatDistance(viewModel.routeDistance))
                    SummaryRow(label: "Est. Time", value: formatDuration(viewModel.routeTime))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    // Helper to format distance
    func formatDistance(_ meters: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        
        let measurement: Measurement<UnitLength>
        
        if meters >= 1000 {
            measurement = Measurement(value: meters / 1000, unit: UnitLength.kilometers)
        } else {
            measurement = Measurement(value: meters, unit: UnitLength.meters)
        }
        
        return formatter.string(from: measurement)
    }
    
    // Helper to format duration
    func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if remainingMinutes == 0 {
                return "\(hours) hr"
            } else {
                return "\(hours) hr \(remainingMinutes) min"
            }
        }
    }
    
    // Helper to determine difficulty color
    func difficultyColor(_ level: Int) -> Color {
        switch level {
        case 1: return .green
        case 2: return .blue
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
}

// Summary Row Component
struct SummaryRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

// Route Map View Container
struct RouteMapViewContainer: UIViewRepresentable {
    @Binding var mapView: MapplsMapView?
    var startLocation: QuestLocation?
    var endLocation: QuestLocation?
    var intermediateLocations: [QuestLocation]
    var routePolyline: String?
    
    func makeUIView(context: Context) -> UIView {
        let mapView = MapplsMapView(frame: .zero)
        mapView.delegate = context.coordinator as? MapplsMapViewDelegate
        
        self.mapView = mapView
        return mapView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let mapView = self.mapView else { return }
        
        // Clear existing annotations and overlays
        mapView.removeAnnotations(mapView.annotations ?? [])
        
        // Fix: Use the correct method to remove overlays
        for overlay in mapView.overlays {
            mapView.remove(overlay)
        }
        
        // Add start and end markers
        if let start = startLocation {
            let annotation = MGLPointAnnotation()
            annotation.coordinate = start.coordinate
            annotation.title = "Start: \(start.name)"
            mapView.addAnnotation(annotation)
        }
        
        if let end = endLocation {
            let annotation = MGLPointAnnotation()
            annotation.coordinate = end.coordinate
            annotation.title = "End: \(end.name)"
            mapView.addAnnotation(annotation)
        }
        
        // Add intermediate locations
        for (index, location) in intermediateLocations.enumerated() {
            let annotation = MGLPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = "Stop \(index + 1): \(location.name)"
            mapView.addAnnotation(annotation)
        }
        
        // Add route polyline if available
        if let routePolyline = routePolyline {
            // Draw the polyline on the map
            if let polyline = decodePolyline(routePolyline) {
                // Fix: Use the correct method to add overlays
                mapView.add(polyline)
            }
        }
        
        // Fit map to show all points
        if let start = startLocation, let end = endLocation {
            let points = [start.coordinate, end.coordinate]
            let polyline = MGLPolyline(coordinates: points, count: UInt(points.count))
            mapView.setVisibleCoordinateBounds(polyline.overlayBounds, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: false)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Make Coordinator conform to MapplsMapViewDelegate explicitly
    class Coordinator: NSObject, MapplsMapViewDelegate {
        var parent: RouteMapViewContainer
        
        init(_ parent: RouteMapViewContainer) {
            self.parent = parent
            super.init()
        }
        
        // Customize marker appearance
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
            if let point = annotation as? MGLPointAnnotation {
                // Determine if this is a start, end, or intermediate point
                let reuseIdentifier = "markerView"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
                
                if annotationView == nil {
                    annotationView = MGLAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                }
                
                // Set appearance based on type
                if point.title?.contains("Start") ?? false {
                    annotationView?.backgroundColor = UIColor.green
                } else if point.title?.contains("End") ?? false {
                    annotationView?.backgroundColor = UIColor.red
                } else {
                    annotationView?.backgroundColor = UIColor.blue
                }
                
                annotationView?.layer.cornerRadius = 5
                annotationView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                                
                                return annotationView
                            }
                            
                            return nil
                        }
                        
                        // Style the route line
                        func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
                            if annotation is MGLPolyline {
                                return UIColor(red: 0.086, green: 0.478, blue: 0.373, alpha: 1.0) // Primary green
                            }
                            return UIColor.blue
                        }
                        
                        func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
                            return 4.0
                        }
                    }
                    
                    // Helper to decode polyline string to MGLPolyline
                    // This is a placeholder implementation - you would need a proper polyline decoder
                    func decodePolyline(_ polyline: String) -> MGLPolyline? {
                        // Mock implementation - in a real app, you'd use a proper polyline decoder
                        if let start = startLocation, let end = endLocation {
                            let points = [start.coordinate, end.coordinate]
                            return MGLPolyline(coordinates: points, count: UInt(points.count))
                        }
                        return nil
                    }
                }
