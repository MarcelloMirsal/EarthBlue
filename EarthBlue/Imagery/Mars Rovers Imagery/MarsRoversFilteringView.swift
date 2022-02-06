//
//  MarsRoversFilteringView.swift
//  EarthBlue
//
//  Created by Marcello Mirsal on 30/01/2022.
//

import SwiftUI

struct MarsRoversFilteringView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: MarsRoversFilteringViewModel
    @State var isCamerasListExpanded = false
    @Binding var feedFiltering: RoverImageryFeedFiltering?
    
    init(roverInfo: RoverInfo, feedFiltering: Binding<RoverImageryFeedFiltering?> ) {
        let viewModel = MarsRoversFilteringViewModel(roverInfo: roverInfo, lastFeedFiltering: feedFiltering.wrappedValue)
        self._viewModel = .init(wrappedValue: viewModel)
        self._feedFiltering = feedFiltering
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section {
                        DatePicker("Imageries date", selection: $viewModel.selectedDate, in: viewModel.filteringDateRange, displayedComponents: .date)
                    }
                    Section {
                        DisclosureGroup(isExpanded: $isCamerasListExpanded) {
                            List(viewModel.roverCameras, id: \.self) { cameraName in
                                Button( action: {
                                    viewModel.select(cameraName: cameraName)
                                }, label: {
                                    HStack {
                                        Text(cameraName.fullName)
                                            .padding(.vertical, 8)
                                        Spacer()
                                        Image(systemName: "checkmark")
                                            .font(.body.weight(.medium))
                                            .opacity(viewModel.isCameraNameSelected(cameraName: cameraName) ? 1 : 0)
                                            .foregroundColor(.blue)
                                    }
                                    .contentShape(Rectangle())
                                })
                                    .buttonStyle(PlainButtonStyle())
                                
                            }
                        } label: {
                            HStack {
                                Text("Select a camera")
                                Spacer()
                                Text(viewModel.selectedCameraName?.rawValue ?? "all")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            dismiss()
                            feedFiltering = viewModel.feedFiltering()
                        } label : {
                            Text("Done")
                                .fontWeight(.bold)
                        }
                    }
                })
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Feed Filtering")
                Button(action: {
                    viewModel.resetFiltering()
                }, label: {
                    Text("Reset defaults")
                        .fontWeight(.semibold)
                })
                    .padding(.bottom, 8)
                    .controlSize(.regular)
                    .buttonStyle(.bordered)
                    .padding(4)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
            }
        }
    }
}

struct MarsRoversFilteringView_Previews: PreviewProvider {
    static var previews: some View {
        MarsRoversFilteringView(roverInfo: RoverInfoFactory.makeCuriosityRoverInfo(), feedFiltering: .constant(nil))
    }
}
