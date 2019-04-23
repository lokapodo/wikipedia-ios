import UIKit

class EditPreviewInternalLinkViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    private var containerViewHeightConstraint: NSLayoutConstraint?
    @IBOutlet private weak var button: UIButton!

    private let articleURL: URL
    private let dataStore: MWKDataStore
    private var theme = Theme.standard

    init(articleURL: URL, dataStore: MWKDataStore) {
        self.articleURL = articleURL
        self.dataStore = dataStore
        super.init(nibName: "EditPreviewInternalLinkViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        button.titleLabel?.font = UIFont.wmf_font(.semiboldSubheadline, compatibleWithTraitCollection: traitCollection)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 8
        button.setTitle(CommonStrings.okTitle, for: .normal)
        wmf_addPeekableChildViewController(for: articleURL, dataStore: dataStore, theme: theme, containerView: containerView)
        apply(theme: theme)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        if let containerViewHeightConstraint = containerViewHeightConstraint {
            containerViewHeightConstraint.constant = constant
        } else {
            containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: constant)
            containerViewHeightConstraint?.isActive = true
        }
    }

    @IBAction private func dismissAnimated(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension EditPreviewInternalLinkViewController: Themeable {
    func apply(theme: Theme) {
        self.theme = theme
        guard viewIfLoaded != nil else {
            return
        }
        button.backgroundColor = theme.colors.baseBackground
        button.tintColor = theme.colors.link
    }
}
