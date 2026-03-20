import ProjectDescription

let project = Project(
    name: "ClaudeShine",
    targets: [
        .target(
            name: "ClaudeShine",
            destinations: .macOS,
            product: .app,
            bundleId: "com.skeswa.claude-shine",
            deploymentTargets: .macOS("14.0"),
            infoPlist: .extendingDefault(with: [
                "LSUIElement": .boolean(true),
                "CFBundleName": .string("Claude Shine"),
                "CFBundleDisplayName": .string("Claude Shine"),
                "NSMainStoryboardFile": .string(""),
            ]),
            sources: ["ClaudeShine/**/*.swift"],
            resources: ["ClaudeShine/Assets.xcassets"],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "5.0",
                ]
            )
        ),
        .target(
            name: "ClaudeShineTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.skeswa.claude-shine-tests",
            deploymentTargets: .macOS("14.0"),
            sources: ["ClaudeShineTests/**/*.swift"],
            dependencies: [
                .target(name: "ClaudeShine"),
            ]
        ),
    ]
)
