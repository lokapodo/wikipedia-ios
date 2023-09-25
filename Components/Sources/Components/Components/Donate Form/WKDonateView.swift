import SwiftUI

public protocol WKDonateDelegate: AnyObject {
    func donateDidTapProblemsDonatingLink()
    func donateDidTapOtherWaysToGive()
    func donateDidTapFrequentlyAskedQuestions()
    func donateDidTapTaxDeductibilityInformation()
    func donateDidSuccessfullySubmitPayment()
}

struct WKDonateView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var appEnvironment = WKAppEnvironment.current
    @ObservedObject var viewModel: WKDonateViewModel
    
    weak var delegate: WKDonateDelegate?
    
    init(viewModel: WKDonateViewModel, delegate: WKDonateDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                WKDonateAmountButtonGroupView(viewModel: viewModel)
                Spacer()
                    .frame(height: 24)
                WKDonateAmountTextfield(viewModel: viewModel.textfieldViewModel)
                if let errorViewModel = viewModel.errorViewModel {
                    WKDonateErrorView(viewModel: errorViewModel)
                }
                Spacer()
                    .frame(height: 24)
                VStack(alignment: .leading, spacing: 12) {
                    WKDonateOptInView(viewModel: viewModel.transactionFeeOptInViewModel)
                    if let emailOptInViewModel = viewModel.emailOptInViewModel {
                        WKDonateOptInView(viewModel: emailOptInViewModel)
                    }
                }
                Spacer()
                    .frame(height: 20)
                WKApplePayDonateButton(configuration: WKApplePayDonateButton.Configuration(paymentButtonStyle: appEnvironment.theme.paymentButtonStyle))
                    .onTapGesture {
                        viewModel.textfieldViewModel.hasFocus = false
                        viewModel.validateAndSubmit()
                        if let errorViewModel = viewModel.errorViewModel {
                            errorViewModel.hasAccessibilityFocus = true
                        }
                    }
                    .accessibilityHint(viewModel.accessibilityDonateButtonHint ?? "")
                    .frame(height: 42)
                    .padding([.leading, .trailing], sizeClassDonateButtonPadding)
                Spacer()
                    .frame(height: 24)
                
                WKDonateHelpLinks(viewModel: viewModel, delegate: delegate)
                Spacer()
            }
            .padding(EdgeInsets(top: 16, leading: sizeClassHorizontalPadding, bottom: 16, trailing: sizeClassHorizontalPadding))
        }
        .background(Color(appEnvironment.theme.paperBackground))
    }
    
    private var sizeClassHorizontalPadding: CGFloat {
        horizontalSizeClass == .regular ? 64 : 32
    }
    
    private var sizeClassDonateButtonPadding: CGFloat {
        horizontalSizeClass == .regular ? 120 : 0
    }
}

private struct WKDonateAmountButtonGroupView: View {
    
    @ObservedObject var viewModel: WKDonateViewModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var contentSizeCategory
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            if shouldDisplayVertically {
                ForEach(viewModel.buttonViewModels) { buttonViewModel in
                    WKDonateAmountButtonView(viewModel: buttonViewModel)
                }
            } else {
                HStack(spacing: 12) {
                    let firstThree = viewModel.buttonViewModels.prefix(3)
                    ForEach(firstThree) { buttonViewModel in
                        WKDonateAmountButtonView(viewModel: buttonViewModel)
                    }
                }
                HStack(spacing: 12) {
                    let lastFour = viewModel.buttonViewModels.suffix(4)
                    ForEach(lastFour) { buttonViewModel in
                        WKDonateAmountButtonView(viewModel: buttonViewModel)
                    }
                }
            }
        }
    }
    
    private var shouldDisplayVertically: Bool {
        return horizontalSizeClass == .compact && (contentSizeCategory == .accessibilityLarge ||
                                                   contentSizeCategory == .accessibilityExtraLarge ||
                                                   contentSizeCategory == .accessibilityExtraExtraLarge ||
                                                   contentSizeCategory == .accessibilityExtraExtraExtraLarge)
    }
}

private struct WKDonateAmountButtonView: View {
    @ObservedObject var viewModel: WKDonateViewModel.AmountButtonViewModel
    
    var body: some View {
        let configuration = WKPriceButton.Configuration(currencyCode: viewModel.currencyCode, canDeselect: false, accessibilityHint: viewModel.accessibilityHint)
        WKPriceButton(configuration: configuration, amount: $viewModel.amount, isSelected: $viewModel.isSelected)
    }
}

private struct WKDonateAmountTextfield: View {
    @ObservedObject var viewModel: WKDonateViewModel.AmountTextFieldViewModel
    
    var body: some View {
        let configuration = WKPriceTextField.Configuration(currencyCode: viewModel.currencyCode, focusOnAppearance: true, doneTitle: viewModel.localizedStrings.doneTitle, textfieldAccessibilityHint: viewModel.localizedStrings.textfieldAccessibilityHint, doneAccessibilityHint: viewModel.localizedStrings.doneAccessibilityHint)
        WKPriceTextField(configuration: configuration, amount: $viewModel.amount, hasFocus: $viewModel.hasFocus)
    }
}

private struct WKDonateErrorView: View {
    
    @ObservedObject var appEnvironment = WKAppEnvironment.current
    @ObservedObject var viewModel: WKDonateViewModel.ErrorViewModel
    
    @AccessibilityFocusState var accessibilityFocus: Bool
    
    var body: some View {
        Spacer()
            .frame(height: 12)
        HStack {
            Text(viewModel.localizedStrings.text)
                .font(Font(WKFont.for(.mediumSubheadline)))
                .foregroundColor(Color(appEnvironment.theme.destructive))
                .accessibilityFocused($accessibilityFocus)
                .onChange(of: viewModel.hasAccessibilityFocus) {
                    accessibilityFocus = $0
                }
                .onChange(of: accessibilityFocus) {
                    viewModel.hasAccessibilityFocus = $0
                }
            Spacer()
        }
    }
}

private struct WKDonateOptInView: View {
    @ObservedObject var appEnvironment = WKAppEnvironment.current
    @ObservedObject var viewModel: WKDonateViewModel.OptInViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            WKCheckmarkView(isSelected: viewModel.isSelected, configuration: WKCheckmarkView.Configuration(style: .checkbox))
                .offset(x: 0, y: 2.5)
                .accessibilityHidden(true)
            Text(viewModel.localizedStrings.text)
                .foregroundColor(Color(appEnvironment.theme.text))
                .font(Font(WKFont.for(.subheadline)))
                .accessibilityHint(viewModel.localizedStrings.accessibilityHint)
                .accessibilityAddTraits( viewModel.isSelected ? [.isSelected] : [])
            Spacer()
        }
        .onTapGesture {
            viewModel.isSelected.toggle()
        }
    }
}

private struct WKDonateHelpLink: View {
    
    @ObservedObject var appEnvironment = WKAppEnvironment.current
    let text: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                Text(text)
                    .foregroundColor(Color(appEnvironment.theme.link))
                    .font(Font(WKFont.for(.subheadline)))
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
    }
}

private struct WKDonateHelpLinks: View {
    @ObservedObject var appEnvironment = WKAppEnvironment.current
    let viewModel: WKDonateViewModel
    weak var delegate: WKDonateDelegate?
    
    init(viewModel: WKDonateViewModel, delegate: WKDonateDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WKDonateHelpLink(text: viewModel.localizedStrings.helpLinkProblemsDonating) {
                delegate?.donateDidTapProblemsDonatingLink()
            }
            WKDonateHelpLink(text: viewModel.localizedStrings.helpLinkOtherWaysToGive) {
                delegate?.donateDidTapOtherWaysToGive()
            }
            WKDonateHelpLink(text: viewModel.localizedStrings.helpLinkFrequentlyAskedQuestions) {
                delegate?.donateDidTapFrequentlyAskedQuestions()
            }
            WKDonateHelpLink(text: viewModel.localizedStrings.helpLinkTaxDeductibilityInformation) {
                delegate?.donateDidTapTaxDeductibilityInformation()
            }
        }
        .padding(EdgeInsets(top: 16, leading: 0, bottom: 28, trailing: 0))
    }
}
